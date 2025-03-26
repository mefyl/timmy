{
  inputs = {
    # Point to our fork until https://github.com/tweag/opam-nix/issues/99 is done
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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
    , gitignore
    , opam-repository
    , routine-opam-repository
    , ...
    }: {
      templates.default = {
        path = ./template;
        description = "Initialize a setup for developing on a Routine OCaml repository";
      };
      lib.mkRoutineRepo = path: { localPackages ? null
                                  # Extra Opam packages to install for development (in the form of an opam-nix query).
                                  # E.g.,
                                  # { acid = "*"; logs = "0.7.0"; }
                                , extraDevPackagesQuery ? { }
                                , extraDevPackages ? (pkgs: [ ])
                                , extraOverlay ? (final: prev: { })
                                , resolveArgsOverride ? (args: args)
                                , extraRepos ? [ ]
                                  # Unfortunately the OCaml version must be passed explicitly because it impacts the development packages (LSP, etc.) provided by the shell.
                                , ocamlVersion ? "5.2.0"
                                ,
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

            # Only keep the Opam files to maximize Nix caching
            opamFilesFilter = gitignore.lib.gitignoreFilterWith {
              basePath = path;
              extraRules = ''
                *
                !*.opam
              '';
            };
            opamFiles = pkgs.lib.cleanSourceWith { src = path; filter = opamFilesFilter; };

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
              # You can add overrides here
              # To add a local, development repo (e.g. your hacked `schematic` rather than the one from Routine's `opam` repo), you can `overrideAttrs` to replace the source like this:
              #
              # schematic = prev.schematic.overrideAttrs (a: {
              #   buildInputs = a.buildInputs or [ ] ++ [ prev.logs ];
              #   src = builtins.fetchGit /home/sir4ur0n/code/routine/schematic;
              # });
              #
              # Remember to update your nix-shell (e.g. with `direnv reload`) after every change in the local repo.
              timmy-jsoo = prev.timmy-jsoo.overrideAttrs (a: { buildInputs = a.nativeBuildInputs or [ ] ++ [ prev.logs ]; });
              timmy-unix = prev.timmy-unix.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ pkgs.tzdata prev.logs ]; });
              timmy-lwt = prev.timmy-lwt.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ prev.logs ]; });
              schematic = prev.schematic.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ prev.logs ]; });
              conf-tzdata = null;
            };

            scope' = scope.overrideScope overlay;

            devPackages = [
              # For some reason, these packages cannot be installed via `opam-nix` as it leads to resolution conflicts 🤷 So we use the Nix packages instead.
              pkgs.ocaml-ng."ocamlPackages_${ocamlPackagesVersion}".ocamlformat_0_26_2
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

              targetPkgs = pkgs: [
                pkgs.xdg-utils
                pkgs.glibc.bin
                pkgs.glib
                pkgs.iana-etc
                pkgs.nss
                pkgs.libdrm
                pkgs.gtk3
                pkgs.pango
                pkgs.nspr
                pkgs.dbus
                pkgs.dbus-glib
                pkgs.cairo
                pkgs.xorg.libX11
                pkgs.xorg.libXext
                pkgs.xorg.libXfixes
                pkgs.xorg.libXrandr
                pkgs.xorg.libxcb
                pkgs.xorg.libXcomposite
              ] ++ pkgs.electron.buildInputs ++ pkgs.electron.unwrapped.buildInputs;

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

          in
          {
            legacyPackages = scope';

            inherit packages;

            devShells.default = pkgs.mkShell {
              NODE_OPTIONS = "--max_old_space_size=4096";
              inputsFrom = builtins.attrValues packages;
              buildInputs =
                devPackages ++
                ciPackages ++
                (extraDevPackages pkgs) ++
                [ routine_run ];
            };
          }
        );
    };
}
