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
, ocamlformatVersion ? "0_26_2"
  /**
    Extra arguments passed directly to `mkShell`
  */
, extraArgs ? { }
}:
let
  ci-packages = import ./ci-packages.nix;
in
pkgs.mkShell
  ({
    packages = [
      # Base OCaml tooling
      pkgs.ocaml
      pkgs.dune_3
      pkgs.opam

      # Dev tooling
      pkgs."ocamlformat_${ocamlformatVersion}"
      pkgs.ocamlPackages.ocaml-lsp
      pkgs.ocamlPackages.merlin

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
