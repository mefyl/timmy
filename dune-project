(lang dune 2.9)

(name timmy)

(version 0.16.1)

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
  (ocaml
   (>= 4.08.0))
  ppx_here
  ppx_deriving
  ptime
  (odoc :with-doc))
 (depopts
  js_of_ocaml
  (schematic
   (and
    (>= 0.17.0)
    (< 0.18.0)))))

(package
 (name timmy-jsoo)
 (synopsis "Js_of_ocaml bindings for Timmy")
 (depends
  (alcotest :with-test)
  (conf-npm :with-test)
  fmt
  js_of_ocaml
  js_of_ocaml-ppx
  (timmy
   (= :version)))
 (depopts
  (schematic-jsoo
   (and
    (>= 0.17.0)
    (< 0.18.0)))))

(package
 (name timmy-unix)
 (synopsis "Unix clock implementation for Timmy")
 (depends
  (alcotest :with-test)
  (conf-tzdata :with-test)
  fmt
  (timmy
   (= :version))))

(package
 (name timmy-lwt)
 (synopsis "Lwt utilities based on Timmy")
 (depends
  (alcotest :with-test)
  (alcotest-lwt :with-test)
  lwt
  (timmy
   (= :version))))

; Timmy-js won't build on OCaml-CI as schematic is not available.
; (package
;  (name timmy-js)
;  (synopsis "Javascript binding of Timmy")
;  (depends
;   (conf-tzdata :with-test)
;   (schematic-jsoo
;    (and
;     (>= 0.17.0)
;     (< 0.18.0)))
;   (timmy-jsoo
;    (= :version))))
