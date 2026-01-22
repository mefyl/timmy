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
let
  logisticPath =
    if builtins.pathExists ./path-to-logistic.nix
    then (import ./path-to-logistic.nix) else ./.logistic;

  logisticFullNixShell = import "${logisticPath}/nix/full-nix-shell.nix";

  thisRoutineRepo = logisticFullNixShell.lib.mkRoutineRepo ./. {
    # Optional parameters to `mkRoutineRepo` go here
  };
in
thisRoutineRepo.devShells.${builtins.currentSystem}.default
```

3. If you want to use another `logistic` repo than the one present in each repo (e.g., to use the same everywhere), you can override the path by creating a file `path-to-logistic.nix` containing that path:
```nix
/home/foobar/code/routine/logistic
```

Note that you can pass some fields to `mkRoutineRepo` to customize the Nix shell. See examples below.

You should:
* Add `shell.nix` to the source control of each repo (they each may vary in the parameters passed to `mkRoutineRepo`)
* Add `path-to-logistic.nix` to the `.gitignore` of each repo

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
This shell provides `dune` (preview version) which then takes care of dependencies and tools (LSP, Merlin, Ocamlformat) via `dune pkg`.

Create a `shell.nix`:

```
let
  logisticPath =
    if builtins.pathExists ./path-to-logistic.nix
    then (import ./path-to-logistic.nix) else ./.logistic;

  shell = import "${logisticPath}/nix/shell.nix" {
    extraPackages = p: [
      p.foo
    ];
  };
in
shell.overrideAttrs (a: {
  # You can override stuff here, like shellHook
})
```

Then create or symlink `.envrc`:

```shell
ln --symbolic .logistic/nix/envrc-shallow .envrc
# Or if you would rather use a global `logistic` repo
cp ../logistic/nix/envrc-shallow ../logistic/nix/envrc-custom
# Edit the path to the `logistic` repo in `../logistic/nix/envrc-custom`, then:
ln --symbolic ../logistic/nix/envrc-custom .envrc
```

Now you need to run these commands:
```
$ dune tools install ocamllsp
$ dune tools install ocamlmerlin
$ dune tools install ocamlformat
$ direnv reload
```
