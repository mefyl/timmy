(dirs :standard .logistic)

(env
 (dev
  (flags
   (:standard -warn-error -A -warn-error +partial-match)))
 (release
  (flags
   (:standard -warn-error +A -w +unused-constructor -w +unused-var-strict)))
 (pedantic
  (flags
   (:standard
    ; Hardcoded (by dune) default compiler flags for the `dev` profile
    ; as there's no way to automatically use them for another profile
    -w
    @1..3@5..28@31..39@43@46..47@49..57@61..62@67@69-40
    -strict-sequence
    -strict-formats
    -short-paths
    -keep-locs
    ;;;
    -warn-error
    +A
    -warn-error
    +partial-match))))

(subdir
 opam
 (rule
  (target dune)
  (mode (promote))
  (action
   (with-stdout-to
    %{target}
    (chdir
     ..
     (pipe-stdout
      (run
       %{workspace_root}/.logistic/ci/dune/dune_sak.exe
       generate
       %{read-strings:../cross.flags})
      (run dune format)))))
  (deps ../dune-project ../.logistic/dune.inc)))
