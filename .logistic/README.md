# Logistic

Shared infrastructure across the various Routine projects.
This repository is meant to be included as a subtree under `.logistic`.

Add it or update it with:

```console
$ git subtree pull --prefix .logistic --squash git@gitlab.routine.co:routine/logistic master
```

## Building with `dune pkg`

To `dune pkg`-ify a repository, both for local builds and the CI, one only need to:

* Add  `(include .logistic/dune.inc)` in the root `dune` file.
* Touch a `cross.flags` at the root. This file may contain flags to be
  passed to `dune_sak` for cross compilation.
* Symlink `.logistic/dune-workspace` to `dune-workspace` if access to
  Routine's internal opam repository is needed.


## Releasing a new version

In order to release a new version of a library using logistic, you need to:

1. Ensure that `.logistic` is up-to-date (see above)
2. Change (or add) the version number in `dune-project`:
    ```
    (version X.Y.Z)
    ```
3. Rebuild the opam files with `dune build *.opam opam/*.opam`
4. Commit as `Prerelease X.Y.Z`
5. Push, and wait for the CI to be green
6. Create an annotated tag with the version number and the message `Prerelease X.Y.Z`

The CI should then push on https://gitlab.routine.co/routine/opam to make the new version available


## Cross compilation

The `dune_sak` binary is responsible, amongst other things, for
generating the cross compilation opam files from the regular opam
files. All dependee packages are cross compiled by default, but one
can manually compile some for both HOST and TARGET using `--cross-both
comma-separated-package-list` or exclude any package from being
cross-compiled with `--cross-exclude
comma-separated-package-list`. These flags are to be written to
`cross.flags` at the root, one per line.


## DEPRECATED - Generating `*.opam.extdeps` files

These files are part of the opam flow which should be replaced by the
`dune pkg` flow as we go.

To generate the `*.opam.extdeps` files (used in CI for Docker caching Opam dependencies), run the following at the root of a repository containing `*.opam` files:
```console
# Refresh the `dune.inc`
$ dune build dune.inc
# Install the packages for which you want to generate the extdeps files
$ opam install ./*.opam
# Generate them
$ dune build @extdeps
```
