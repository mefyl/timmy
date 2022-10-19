(lang dune 2.9)

(name timmy)

(version 0.14.1)

(generate_opam_files true)

(executables_implicit_empty_intf true)

(license LGPL-3.0-or-later)

(maintainers "mefyl <mefyl@gruntech.org>")

(authors "mefyl <mefyl@gruntech.org>")

(homepage https://github.com/mefyl/timmy)

(bug_reports https://github.com/mefyl/timmy/issues)

(source
 (github mefyl/timmy))

(package
 (name timmy)
 (synopsis "Time and calendar library")
 (depends
  (alcotest :with-test)
  base
  fmt
  ppx_here
  ppx_deriving
  ptime
  (odoc (and :with-doc (= 2.0.2))))
 (depopts
  js_of_ocaml
  (schematic
   (and
    (>= 0.15.0)
    (< 0.16.0)))))

(package
 (name timmy-jsoo)
 (synopsis "Js_of_ocaml bindings for Timmy")
 (depends
  (alcotest :with-test)
  fmt
  js_of_ocaml
  js_of_ocaml-ppx
  (timmy
   (= :version)))
 (depopts
  (schematic-jsoo
   (and
    (>= 0.15.0)
    (< 0.16.0)))))
