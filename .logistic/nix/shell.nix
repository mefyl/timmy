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
    The ocamlformat version (formatted as Nix wants it).
    To keep in sync with the one in .ocamlformat
  */
, ocamlformatVersion ? "0_27_0"
  /**
    Extra arguments passed directly to `mkShell`
  */
, ocamlVersion
, extraArgs ? { }
}:
let
  ci-packages = import ./ci-packages.nix { inherit pkgs; };

  dune-preview = (import srcs.flake-compat { src = srcs.dune; }).outputs.packages.${pkgs.system}.dune-experimental;
in
pkgs.mkShell
  ({
    packages = [
      # Base OCaml tooling
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}".ocaml
      dune-preview
      pkgs.opam

      # Dev tooling
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}"."ocamlformat_${ocamlformatVersion}"
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}".ocaml-lsp
      pkgs.ocaml-ng."ocamlPackages_${ocamlVersion}".merlin

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
