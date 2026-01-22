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
    Extra arguments passed directly to `mkShell`
  */
, extraArgs ? { }
}:
let
  ci-packages = import ./ci-packages.nix { inherit pkgs; };

  dune-preview = (import srcs.flake-compat { src = srcs.dune; }).outputs.packages.${pkgs.system}.dune;
  shared =
    import ./shared.nix { inherit pkgs; };
in
pkgs.mkShell
  ({
    packages = [
      # Base OCaml tooling
      dune-preview

      # Dev tooling
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
