{ srcs ? import ./sources.nix { }
, pkgs ? import srcs.nixpkgs {
    # Required for steam-run (Linux only)
    config.allowUnfree = true;
  }
, /**
  Extra packages to add to the shell.
  */
  extraPackages ? (pkgs: [ ])
, /**
  Extra arguments passed directly to `mkShell`
  */
  extraArgs ? { }
,
}:
let
  ci-packages = import ./ci-packages.nix { inherit pkgs; };

  dune-preview =
    (import srcs.flake-compat { src = srcs.dune; }).outputs.packages.${pkgs.stdenv.hostPlatform.system}.dune;
  shared = import ./shared.nix { inherit pkgs; };
in
pkgs.mkShell (
  {
    packages = [
      # Base OCaml tooling
      dune-preview

      # System libraries
      pkgs.autoconf
      pkgs.gmp.dev
      pkgs.libev
      pkgs.libffi
      pkgs.openssl.dev
      pkgs.pkg-config
      pkgs.postgresql
      pkgs.sqlite
      pkgs.zlib.dev
      pkgs.binaryen

      # JS tooling
      pkgs.yarn
      pkgs.nodejs
    ]
    ++
    # Linux-only tools (NixOS FHS wrapper, AppImage/Steam runners)
    pkgs.lib.optionals pkgs.stdenv.isLinux [
      shared.routine_run
      pkgs.appimage-run
      pkgs.steam-run
    ]
    ++ ci-packages
    ++ (extraPackages pkgs);

  }
    // extraArgs
)
