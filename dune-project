(lang dune 2.8)

(name timmy)

(version 0.6.0)

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
  acid
  (alcotest :with-test)
  fmt
  ptime
  (schematic
   (= 0.6.0)))
 (depopts js_of_ocaml))
