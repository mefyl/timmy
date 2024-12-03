# Logistic

Shared infrastructure across the various Routine projects.
This repository is meant to be included as a subtree under `.logistic`.

Add it or update it with:

```console
$ git subtree pull --prefix .logistic --squash git@gitlab.routine.co:routine/logistic master
```

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

## Generating `*.opam.extdeps` files

To generate the `*.opam.extdeps` files (used in CI for Docker caching Opam dependencies), run the following at the root of a repository containing `*.opam` files:
```console
# Refresh the `dune.inc`
$ dune build dune.inc
# Install the packages for which you want to generate the extdeps files
$ opam install ./*.opam
# Generate them
$ dune build @extdeps
```
