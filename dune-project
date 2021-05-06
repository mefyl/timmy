(lang dune 2.7)

(name timmy)

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
  fmt
  js_of_ocaml
  js_of_ocaml-ppx
  ptime
  schematic
  schematic-jsoo))
