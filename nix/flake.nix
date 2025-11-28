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

    dune = {
      url = "github:ocaml/dune";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };
  outputs =
    { self
    , flake-utils
    , opam-nix
    , nixpkgs
    , opam-repository
    , routine-opam-repository
    , dune
    , ...
    }: {
      templates.default = {
        path = ./template;
        description = "Initialize a setup for developing on a Routine OCaml repository";
      };
      lib.mkRoutineRepo =
        path:
        { localPackages ? null
          # A function for building the set of opam files to take into account in the local repository.
          # Takes `nixpkgs` as argument to allow using the lib functions (`fileset` in particular), and should return a `fileset`
          #
          # If `null`, all the non-cross packages in the repository will be used
        , opamFiles ? null
          # Extra Opam packages to install for development (in the form of an opam-nix query).
          # E.g.,
          # { acid = "*"; logs = "0.7.0"; }
        , extraDevPackagesQuery ? { }
        , extraDevPackages ? (pkgs: [ ])
          # An extra overlay applied to the OCaml packages set.
          # The first argument is the global pkgs set, the two other ones are the standard overlay arguments for the OCaml pkg set.
        , extraOCamlOverlay ? (pkgs: final: prev: { })
        , resolveArgsOverride ? (args: args)
        , extraRepos ? [ ]
          # Unfortunately the OCaml version must be passed explicitly because it impacts the development packages (LSP, etc.) provided by the shell.
        , ocamlVersion
          # Force a specific ocamlformat version, e.g. `"0.26.2"`.
        , ocamlformatVersion ? null
          # Whether to make the shell swift-compatible.
          # This isn't enabled by default as it is
          # somewhat invasive (forcing the stdenv to use clang in particular)
        , withSwift ? false
        }:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            pkgs = import nixpkgs {
              inherit system;
              # Required for steam-run
              config.allowUnfree = true;
            };
            shared = import ./shared.nix { inherit pkgs; };
            ocamlformatVersion_ =
              if ocamlformatVersion == null
              then
                shared.ocamlformatVersionFromDotOcamlformat (path + "/.ocamlformat")
              else
                ocamlformatVersion;
            # Only keep root opam files
            opamFiles_ =
              let
                opamFilesWithoutCrossCompilation =
                  pkgs.lib.fileset.fileFilter
                    (file: file.hasExt "opam"
                      && !(pkgs.lib.hasSuffix "-android.opam" file.name)
                      && !(pkgs.lib.hasSuffix "-ios.opam" file.name)
                      && !(pkgs.lib.hasSuffix "-macos.opam" file.name)
                      && !(pkgs.lib.hasSuffix "-windows.opam" file.name))
                    path;
                gitTracked = pkgs.lib.fileset.gitTrackedWith { recurseSubmodules = true; } path;
                allOpamFiles =
                  if opamFiles != null then
                    (opamFiles pkgs)
                  else
                    pkgs.lib.fileset.intersection gitTracked opamFilesWithoutCrossCompilation;
              in
              pkgs.lib.fileset.toSource {
                root = path;
                fileset = allOpamFiles;
              };

            on = opam-nix.lib.${system};

            localPackages_ = if localPackages != null then localPackages else
            builtins.attrNames
              (builtins.mapAttrs (_: pkgs.lib.last)
                (on.listRepo (on.makeOpamRepoRec opamFiles_)));

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
                  ocaml-lsp-server = "*";
                  merlin = "*";
                  ocamlformat = ocamlformatVersion_;
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

            # Extend the base Opam repository with a (incorrect but not important) version of dune that does not yet exist, so that Opam resolver gives us a break (since we use an unreleased version of Dune)
            opam-repository-extended = let version = "3.20.0"; in pkgs.stdenv.mkDerivation
              {
                name = "opam-repository";
                inherit version;
                src = opam-repository;
                installPhase = ''
                  cp -r $src $out
                  chmod -R u+w $out
                  cp -r $out/packages/dune/dune.3.18.2 $out/packages/dune/dune.${version}
                '';
              };

            scope =
              on.buildOpamProject'
                (resolveArgsOverride {
                  repos = [ opam-repository-extended routine-opam-repository ] ++ extraRepos;
                  recursive = true;
                  resolveArgs.with-test = true;
                  resolveArgs.criteria = "-removed,-count[avoid-version:,true],-count[version-lag:,true],-changed,-count[version-lag:,false],-count[missing-depexts:,true],-new";
                })
                opamFiles_
                query;

            overlay = final: prev:
              let overrideIfExists = name: override: if prev ? "${name}" then prev."${name}".overrideAttrs override else null; in
              {
                # You can add overrides here or pass them from each individual `shell.nix` via `extraOCamlOverlay`.
                # To add a local, development repo (e.g. your hacked `schematic` rather than the one from Routine's `opam` repo), you can `overrideAttrs` to replace the source like this:
                #
                # schematic = prev.schematic.overrideAttrs (a: {
                #   buildInputs = a.buildInputs or [ ] ++ [ prev.logs ];
                #   src = builtins.fetchGit /home/sir4ur0n/code/routine/schematic;
                # });
                #
                # Remember to update your nix-shell (e.g. with `direnv reload`) after every change in the local repo.
                acid = prev.acid.overrideAttrs (a: {
                  doCheck = false;
                });
                acid-jsoo = prev.acid-jsoo.overrideAttrs (a: { buildInputs = a.nativeBuildInputs or [ ] ++ [ final.acid-lwt ]; });
                acid-lwt = prev.acid-lwt.overrideAttrs (a: {
                  doCheck = false;
                });

                cohttp = prev.cohttp.overrideAttrs (a: {
                  buildInputs = a.nativeBuildInputs or [ ] ++ [
                    (final.http or null)
                  ];
                });
                cohttp-eio = prev.cohttp-eio.overrideAttrs (a: {
                  # Because of our pin of cohttp 6.0.0~beta2, which is weird
                  buildInputs = a.nativeBuildInputs or [ ] ++ [
                    prev.uri
                    prev.logs
                    prev.fmt

                    final.http
                    final.cohttp
                  ];
                });
                cohttp-lwt-unix = prev.cohttp-lwt-unix.overrideAttrs (a: {
                  doCheck = false;
                });

                # On NixOS, this looks for timezone files in a non-existent location.
                conf-tzdata = null;

                crdt = prev.crdt.overrideAttrs (a: {
                  doCheck = false;
                });

                # We at Routine must use a very recent, not yet released version of Dune because we use `dune pkg`...
                dune = dune.packages.${system}.dune-experimental;
                dune-configurator = prev.dune-configurator.overrideAttrs (a: {
                  src = dune.packages.${system}.dune-experimental.src;
                  nativeBuildInputs = a.nativeBuildInputs or [ ] ++ [ pkgs.git ];
                  preBuild = ''
                    git init
                  '';
                });

                gapi = prev.gapi.overrideAttrs (a: {
                  doCheck = false;
                });

                landmarks = prev.landmarks.overrideAttrs (a: {
                  doCheck = false;
                });
                landmarks-ppx = prev.landmarks-ppx.overrideAttrs (a: {
                  doCheck = false;
                });

                lcs = prev.lcs.overrideAttrs (a: {
                  doCheck = false;
                });

                mandate = prev.mandate.overrideAttrs (a: {
                  doCheck = false;
                });

                mellifera = prev.mellifera.overrideAttrs (a: {
                  doCheck = false;
                });
                mellifera-cohttp = prev.mellifera-cohttp.overrideAttrs (a: {
                  doCheck = false;
                });
                mellifera-httpaf = prev.mellifera-httpaf.overrideAttrs (a: {
                  doCheck = false;
                });

                memtrace = prev.memtrace.overrideAttrs (a: {
                  doCheck = false;
                });

                merlin = prev.merlin.overrideAttrs (a: {
                  doCheck = false;
                });

                mrou = prev.mrou.overrideAttrs (a: {
                  doCheck = false;
                });

                nofuture = prev.nofuture.overrideAttrs (a: {
                  buildInputs = a.nativeBuildInputs or [ ] ++ [
                    prev.ocaml
                  ];
                });

                ocaml-compiler = prev.ocaml-compiler.overrideAttrs (a: {
                  buildInputs = a.buildInputs ++ [ pkgs.zstd ];
                });

                rfc5545 = prev.rfc5545.overrideAttrs (a: {
                  doCheck = false;
                });

                routine-crdt = prev.routine-crdt.overrideAttrs (a: {
                  doCheck = false;
                });
                routine-metrics = prev.routine-metrics.overrideAttrs (a: {
                  doCheck = false;
                });
                routine-schemas = prev.routine-schemas.overrideAttrs (a: {
                  doCheck = false;
                });

                schematic = overrideIfExists "schematic" (a: {
                  doCheck = false;
                });
                schematic-cohttp-eio = prev.schematic-cohttp-eio.overrideAttrs (a: {
                  doCheck = false;
                });
                schematic-http = prev.schematic-http.overrideAttrs (a: {
                  buildInputs = a.nativeBuildInputs or [ ] ++ [ prev.logs ];
                });
                schematic-jsoo = overrideIfExists "schematic-jsoo" (a: {
                  doCheck = false;
                });

                sqml-caqti = prev.sqml-caqti.overrideAttrs (a: {
                  doCheck = false;
                });

                stripe = prev.stripe.overrideAttrs (a: {
                  doCheck = false;
                });
                stripe-schemas = prev.stripe-schemas.overrideAttrs (a: {
                  doCheck = false;
                });

                timmy-jsoo = overrideIfExists "timmy-jsoo" (a: {
                  buildInputs = a.nativeBuildInputs or [ ] ++ [ prev.logs ];
                });
                timmy-lwt = prev.timmy-lwt.overrideAttrs (a: {
                  doCheck = false;
                  buildInputs = a.buildInputs or [ ] ++ [ prev.logs ];
                });
                timmy-timezones = prev.timmy-timezones.overrideAttrs (a: {
                  doCheck = false;
                });
                timmy-unix = prev.timmy-unix.overrideAttrs (a: {
                  doCheck = false;
                  buildInputs = a.buildInputs or [ ] ++ [ pkgs.tzdata prev.logs ];
                });
              };

            scope' = scope.overrideScope (pkgs.lib.composeExtensions overlay (extraOCamlOverlay pkgs));

            devPackages = [
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

            routine_run = shared.routine_run;

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
                TZ = "Europe/Paris";
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
