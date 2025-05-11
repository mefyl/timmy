(dirs :standard .logistic)

(env
 (dev
  (flags
   (:standard -warn-error -A -warn-error +partial-match)))
 (release
  (flags
   (:standard -warn-error +A -w +unused-constructor))))

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
       %{dep:../.logistic/ci/dune/dune_sak.exe}
       generate
       %{read-strings:../cross.flags})
      (run dune format)))))
  (deps ../dune-project ../.logistic/dune.inc)))
