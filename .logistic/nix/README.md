# Nix setup for the Routine projects

This directory provides 2 Nix shells: a full one and a shallow one.

Both require `direnv` and `nix` to be installed.
Additionally, we recommend installing `nix-direnv`.

## Full shell
This shell takes care of installing all Opam packages.
You do not need to interact with `opam` anymore ❤️

To use it:
1. Create a symlink to the "full" envrc:
```shell
ln --symbolic .logistic/nix/envrc-full .envrc
# Or if you would rather use a global `logistic` repo
ln --symbolic ../logistic/nix/envrc-full .envrc
```

2. Create a file `shell.nix`:
```nix
# shell.nix
((import ./.logistic/nix/full-nix-shell.nix).lib.mkRoutineRepo ./. { }).devShells.x86_64-linux.default
# Or if you would rather use a global `logistic` repo
((import ../logistic/nix/full-nix-shell.nix).lib.mkRoutineRepo ./. { }).devShells.x86_64-linux.default
```

Note that you can pass some fields to `mkRoutineRepo` to customize the Nix shell. See examples below.

### Add Opam packages to the shell
Sometimes you want to install extra Opam packages, e.g. for development, or because some `dune` files does not have a corresponding top-level `.opam` file.
In that case, pass an [opam-nix](https://github.com/tweag/opam-nix/blob/main/DOCUMENTATION.md)-compatible query to `extraDevPackagesQuery`:
```nix
# shell.nix
let
  # Dependencies needed for `update-notes` which does not have an Opam file for some reason.
  updateNotesQuery =
    {
      acid = "*";
      logs = "*";
      omd = "*";
      re = "*";
      semver2 = "*";
      timmy = "*";
    };
in
((import ../logistic/nix/full-nix-shell.nix).lib.mkRoutineRepo ./. { extraDevPackagesQuery = updateNotesQuery; }).devShells.x86_64-linux.default
```

### Change the default OCaml version
The default OCaml version is set in `flake.nix` but you can customize it by passing an `ocamlVersion`:
```nix
# shell.nix
((import ../logistic/nix/full-nix-shell.nix).lib.mkRoutineRepo ./. { ocamlVersion = "5.1.1"; }).devShells.x86_64-linux.default
```

## Shallow shell
This shell provides `dune`, `opam`, etc., but you will need to run all the `opam` commands to install the OCaml packages, etc., for **each** repository, as well as re-run the right commands whenever the `.opam` files change.

```shell
ln --symbolic .logistic/nix/envrc-shallow .envrc
# Or if you would rather use a global `logistic` repo
cp ../logistic/nix/envrc-shallow ../logistic/nix/envrc-custom
# Edit the path to the `logistic` repo in `../logistic/nix/envrc-custom`, then:
ln --symbolic ../logistic/nix/envrc-custom .envrc
```
