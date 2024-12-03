# Use: Create a `shell.nix` file in each OCaml repo with this content:
#
# ((import <path to logistic repo>/nix/full-nix-shell.nix).lib.mkRoutineRepo ./. { }).devShells.x86_64-linux.default
(import
  (
    let lock = builtins.fromJSON (builtins.readFile ./flake.lock);
    in fetchTarball {
      url =
        "https://github.com/edolstra/flake-compat/archive/${lock.nodes.flake-compat.locked.rev}.tar.gz";
      sha256 = lock.nodes.flake-compat.locked.narHash;
    }
  )
  { src = ./.; }).defaultNix
