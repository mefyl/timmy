(lang dune 2.8)

(name timmy)

(version 0.11.10)

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
  (alcotest :with-test)
  base
  fmt
  ppx_here
  ppx_deriving
  ptime)
 (depopts
  js_of_ocaml
  (schematic
   (and
    (>= 0.11.9)
    (< 0.12.0)))))

(package
 (name timmy-jsoo)
 (synopsis "Js_of_ocaml bindings for Timmy")
 (depends
  (alcotest :with-test)
  fmt
  js_of_ocaml
  js_of_ocaml-ppx
  (schematic-jsoo
   (and
    (>= 0.11.9)
    (< 0.12.0)))
  (timmy
   (= :version))))
