{ srcs ? import ./sources.nix { }
, pkgs ? import srcs.nixpkgs {
    # Required for steam-run
    config.allowUnfree = true;
  }
  /**
    Extra packages to add to the shell.
  */
, extraPackages ? (pkgs: [ ])
  /**
    The path to a `.ocamlformat` file from which to extract the version.
  */
, dotOcamlformatPath ? null
  /**
    The ocamlformat version (formatted as Nix wants it).

    Takes precedence over the one inferred from `dotOcamlformatPath`.
  */
, ocamlformatVersion ? null
  /**
    Extra arguments passed directly to `mkShell`
  */
, ocamlVersion
, extraArgs ? { }
} @ args:
let
  ci-packages = import ./ci-packages.nix { inherit pkgs; };

  dune-preview = (import srcs.flake-compat { src = srcs.dune; }).outputs.packages.${pkgs.system}.dune-experimental;
  shared =
    import ./shared.nix { inherit pkgs; };
  ocamlformatVersion_ =
    if ocamlformatVersion != null then args.ocamlformatVersion else
    if dotOcamlformatPath != null then
      builtins.replaceStrings [ "." ] [ "_" ]
        (shared.ocamlformatVersionFromDotOcamlformat dotOcamlformatPath)
    else throw "One of 'ocamlformatVersion' or 'dotOcamlformatPath' must be supplied";
in
pkgs.mkShell
  ({
    packages = [
      # Base OCaml tooling
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}".ocaml
      dune-preview
      pkgs.opam

      # Dev tooling
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}"."ocamlformat_${ocamlformatVersion_}"
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}".ocaml-lsp
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}".merlin
      shared.routine_run

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
    ci-packages ++
    (extraPackages pkgs);

  } // extraArgs)
