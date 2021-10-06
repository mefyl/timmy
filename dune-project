(lang dune 2.8)

(name timmy)

(version 0.10.1)

(generate_opam_files true)

(license GPLv3)

(maintainers "mefyl <mefyl@gruntech.org>")

(authors "mefyl <mefyl@gruntech.org>")

(homepage https://gitlab.routine.co/routine/timmy)

(bug_reports https://gitlab.routine.co/routine/timmy/-/issues)

(package
 (name timmy)
 (synopsis "Time library")
 (depends
  (acid
   (and
    (>= 0.5.0)
    (< 0.6.0)))
  (alcotest :with-test)
  fmt
  ptime
  (schematic
   (= 0.9.0)))
 (depopts js_of_ocaml))

(package
 (name timmy-jsoo)
 (synopsis "Js_of_ocaml bindings for Timmy")
 (depends
  (alcotest :with-test)
  fmt
  js_of_ocaml
  js_of_ocaml-ppx
  (timmy
   (= :version))))
