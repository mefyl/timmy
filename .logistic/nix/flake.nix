{
  inputs = {
    # Point to our fork until https://github.com/tweag/opam-nix/issues/99 is done
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-compat.follows = "flake-compat";
        flake-utils.follows = "flake-utils";
        opam-repository.follows = "opam-repository";
      };
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };

    routine-opam-repository = {
      url = "git+ssh://git@gitlab.routine.co/routine/opam.git";
      flake = false;
    };
  };
  outputs =
    { self
    , flake-utils
    , opam-nix
    , nixpkgs
    , opam-repository
    , routine-opam-repository
    , ...
    }: {
      templates.default = {
        path = ./template;
        description = "Initialize a setup for developing on a Routine OCaml repository";
      };
      lib.mkRoutineRepo =
        path:
        { localPackages ? null
          # Extra Opam packages to install for development (in the form of an opam-nix query).
          # E.g.,
          # { acid = "*"; logs = "0.7.0"; }
        , extraDevPackagesQuery ? { }
        , extraDevPackages ? (pkgs: [ ])
        # An extra overlay applied to the OCaml packages set.
        # The first argument is the global pkgs set, the two other ones are the standard overlay arguments for the OCaml pkg set.
        , extraOCamlOverlay ? (pkgs: final: prev: { })
          # Regexes to filter in the opam files to pick
        , opamFilesRegexes ? [ "^.*\\.opam$" ]
        , resolveArgsOverride ? (args: args)
        , extraRepos ? [ ]
          # Unfortunately the OCaml version must be passed explicitly because it impacts the development packages (LSP, etc.) provided by the shell.
        , ocamlVersion ? "5.2.0"
        , withSwift ? false
          # Whether to make the shell swift-compatible.
          # This isn't enabled by default as it is
          # somewhat invasive (forcing the stdenv to use clang in particular)
        }:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            ocamlPackagesVersion =
              let parsedVersion = builtins.splitVersion ocamlVersion;
              in builtins.elemAt parsedVersion 0 + "_" + builtins.elemAt parsedVersion 1;

            pkgs = import nixpkgs {
              inherit system;
              # Required for steam-run
              config.allowUnfree = true;
            };

            # Only keep root opam files
            opamFiles = pkgs.lib.sourceByRegex path opamFilesRegexes;

            on = opam-nix.lib.${system};

            localPackages_ = if localPackages != null then localPackages else
            builtins.attrNames
              (builtins.mapAttrs (_: pkgs.lib.last)
                (on.listRepo (on.makeOpamRepo opamFiles)));

            # You can add "development" Opam packages here. They will get added to the devShell automatically.
            devPackagesQuery =
              let
                # Dependencies needed for `extdeps.exe` which does not have an Opam file for some reason.
                # `extdeps.exe` is present in all our repositories (part of `logistic`) so we put the dependencies here rather than in each single `shell.nix`.
                extdepsQuery =
                  {
                    cmdliner = "*";
                    fmt = "*";
                    opam-file-format = "*";
                    sexplib = "*";
                    stdio = "*";
                  };

                # Useful development packages
                developmentQuery = {
                  utop = "*";
                } // pkgs.lib.optionalAttrs
                  (builtins.compareVersions ocamlVersion "5.2.0" >= 0)
                  {
                    # `ocaml-index` requires OCaml >= 5.2.0
                    ocaml-index = "*";
                  };
              in
              extdepsQuery //
              developmentQuery //
              extraDevPackagesQuery;

            query =
              devPackagesQuery
              // {
                ocaml-base-compiler = ocamlVersion;
                angstrom = "0.15.0";
              };

            scope =
              on.buildOpamProject'
                (resolveArgsOverride {
                  repos = [ opam-repository routine-opam-repository ] ++ extraRepos;
                  resolveArgs.with-test = true;
                  resolveArgs.criteria = "-removed,-count[avoid-version:,true],-count[version-lag:,true],-changed,-count[version-lag:,false],-count[missing-depexts:,true],-new";
                })
                opamFiles
                query;

            overlay = final: prev: {
              # You can add overrides here or pass them from each individual `shell.nix` via `extraOCamlOverlay`.
              # To add a local, development repo (e.g. your hacked `schematic` rather than the one from Routine's `opam` repo), you can `overrideAttrs` to replace the source like this:
              #
              # schematic = prev.schematic.overrideAttrs (a: {
              #   buildInputs = a.buildInputs or [ ] ++ [ prev.logs ];
              #   src = builtins.fetchGit /home/sir4ur0n/code/routine/schematic;
              # });
              #
              # Remember to update your nix-shell (e.g. with `direnv reload`) after every change in the local repo.
              schematic-http = prev.schematic-http.overrideAttrs (a: { buildInputs = a.nativeBuildInputs or [ ] ++ [ prev.logs ]; });
              timmy-jsoo = prev.timmy-jsoo.overrideAttrs (a: { buildInputs = a.nativeBuildInputs or [ ] ++ [ prev.logs ]; });
              timmy-unix = prev.timmy-unix.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ pkgs.tzdata prev.logs ]; });
              timmy-lwt = prev.timmy-lwt.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ prev.logs ]; });
              acid-jsoo = prev.acid-jsoo.overrideAttrs (a: { buildInputs = a.nativeBuildInputs or [ ] ++ [ final.acid-lwt ]; });

              # On NixOS, this looks for timezone files in a non-existent location.
              conf-tzdata = null;

              utop = prev.utop.overrideAttrs (a: {
                # Utop has multiple root directories and Nix only wants one
                sourceRoot = ".";
              });

              landmarks = prev.landmarks.overrideAttrs (a: {
                doCheck = false;
              });

              landmarks-ppx = prev.landmarks-ppx.overrideAttrs (a: {
                doCheck = false;
              });

              # Because of our pin of cohttp 6.0.0~beta2, which is weird
              cohttp-eio = prev.cohttp-eio.overrideAttrs (a: {
                buildInputs = a.nativeBuildInputs or [ ] ++ [
                  prev.uri
                  prev.logs
                  prev.fmt

                  final.http
                  final.cohttp
                ];
              });
              cohttp = prev.cohttp.overrideAttrs (a: {
                buildInputs = a.nativeBuildInputs or [ ] ++ [
                  (final.http or null)
                ];
              });

              cohttp-lwt-unix = prev.cohttp-lwt-unix.overrideAttrs (a: {
                doCheck = false;
              });

              schematic = prev.schematic.overrideAttrs (a: {
                doCheck = false;
              });
              timmy-timezones = prev.timmy-timezones.overrideAttrs (a: {
                doCheck = false;
              });
              acid = prev.acid.overrideAttrs (a: {
                doCheck = false;
              });
              acid-lwt = prev.acid-lwt.overrideAttrs (a: {
                doCheck = false;
              });
              stripe-schemas = prev.stripe-schemas.overrideAttrs (a: {
                doCheck = false;
              });
              gapi = prev.gapi.overrideAttrs (a: {
                doCheck = false;
              });
              crdt = prev.crdt.overrideAttrs (a: {
                doCheck = false;
              });
              mandate = prev.mandate.overrideAttrs (a: {
                doCheck = false;
              });
              stripe = prev.stripe.overrideAttrs (a: {
                doCheck = false;
              });
              sqml-caqti = prev.sqml-caqti.overrideAttrs (a: {
                doCheck = false;
              });
              routine-schemas = prev.routine-schemas.overrideAttrs (a: {
                doCheck = false;
              });
              rfc5545 = prev.rfc5545.overrideAttrs (a: {
                doCheck = false;
              });
              lcs = prev.lcs.overrideAttrs (a: {
                doCheck = false;
              });
              mellifera = prev.mellifera.overrideAttrs (a: {
                doCheck = false;
              });
              mellifera-httpaf = prev.mellifera-httpaf.overrideAttrs (a: {
                doCheck = false;
              });
              mrou = prev.mrou.overrideAttrs (a: {
                doCheck = false;
              });
              routine-metrics = prev.routine-metrics.overrideAttrs (a: {
                doCheck = false;
              });
              routine-crdt = prev.routine-crdt.overrideAttrs (a: {
                doCheck = false;
              });
            };

            scope' = scope.overrideScope (pkgs.lib.composeExtensions overlay (extraOCamlOverlay pkgs));

            devPackages = [
              # For some reason, these packages cannot be installed via `opam-nix` as it leads to resolution conflicts 🤷 So we use the Nix packages instead.
              pkgs.ocaml-ng."ocamlPackages_${ocamlPackagesVersion}".ocamlformat_0_27_0
              pkgs.ocaml-ng."ocamlPackages_${ocamlPackagesVersion}".ocaml-lsp
              pkgs.ocaml-ng."ocamlPackages_${ocamlPackagesVersion}".merlin

              # System libraries
              pkgs.appimage-run
              pkgs.autoconf
              pkgs.gmp.dev
              pkgs.libev
              pkgs.libffi
              pkgs.openssl.dev
              pkgs.pkg-config
              pkgs.postgresql
              pkgs.sqlite
              pkgs.steam-run
              pkgs.zlib.dev

              # JS tooling
              pkgs.yarn
              pkgs.nodejs
            ] ++
            builtins.attrValues
              (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');

            # Packages in this workspace
            packages =
              pkgs.lib.getAttrs localPackages_ scope';

            routine_run = pkgs.buildFHSEnv {
              name = "routine-run";

              targetPkgs = pkgs:
                (pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs pkgs) ++
                (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs);

              runScript = pkgs.writers.writeBash "routine-run" ''
                executable="''${1:-./dist_electron/linux-unpacked/routine}"
                shift

                exec "$executable" "$@"
              '';

              TZ = "Europe/Paris";

            };

            ciPackages = import ./ci-packages.nix {
              inherit pkgs;
            };

            swiftPackages = let p = pkgs; in [
              p.swift
              p.swiftPackages.Dispatch
              p.swiftPackages.Foundation
              p.swift-format
              p.swift-corelibs-libdispatch
              p.gcc
            ];

          in
          {
            legacyPackages = scope';

            inherit packages;

            devShells.default =
              let mkShell = if withSwift then pkgs.mkShell.override { stdenv = pkgs.clangStdenv; } else pkgs.mkShell; in
              mkShell {
                NODE_OPTIONS = "--max_old_space_size=4096";
                inputsFrom = builtins.attrValues packages;
                buildInputs =
                  devPackages ++
                  ciPackages ++
                  (extraDevPackages pkgs) ++
                  (if withSwift then swiftPackages else [ ]) ++
                  [ routine_run ];
              };
          }
        );
    };
}
