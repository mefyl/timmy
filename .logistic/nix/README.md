# Nix setup for the routine projects

This folder provides a simple `shell.nix` for developing on the Routine repositories.

It requires `direnv` and `nix` to be installed.

Link `.logistic/nix/envrc` to `.envrc` at the root of your project:

```shell
ln --symbolic .logistic/nix/envrc .envrc
```
