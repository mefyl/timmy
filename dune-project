(lang dune 3.0)

(name timmy)

(version 1.1.6)

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
  base
  (fmt
   (>= 0.8.7))
  (ocaml
   (>= 4.08.0))
  ppx_here
  (ppx_deriving
   (>= 5.0))
  ptime
  ; Test
  (alcotest
   (and
    :with-test
    (>= 1.4.0)))
  ; Doc
  (odoc :with-doc)
  ; Dev
  ; These should become only :with-dev-setup when `dune pkg` supports it.
  (cmdliner
   (or :with-dev-setup :with-test))
  (ocamlformat
   (and
    (= 0.26.2)
    (or :with-dev-setup :with-test)))
  (opam-file-format
   (or :with-dev-setup :with-test))
  (sexplib
   (or :with-dev-setup :with-test))
  (stdio
   (or :with-dev-setup :with-test)))
 (depopts js_of_ocaml js_of_ocaml-ppx schematic)
 (conflicts
  (schematic
    (or
    (< 0.18.2)
    (= 0.20.0)
    (>= 0.21.0)))))

(package
 (name timmy-jsoo)
 (synopsis "Js_of_ocaml bindings for Timmy")
 (depends
  ptime
  ppx_here
  (alcotest
   (and
    :with-test
    (>= 1.4.0)))
  (conf-npm :with-test)
  fmt
  js_of_ocaml
  js_of_ocaml-ppx
  (timmy
   (= :version)))
 (depopts schematic-jsoo)
 (conflicts
  (schematic-jsoo
   (or
    (< 0.18.2)
    (>= 0.21.0)))))

(package
 (name timmy-unix)
 (synopsis "Unix clock implementation for Timmy")
 (depends
  ptime
  (alcotest
   (and
    :with-test
    (>= 1.4.0)))
  (ezjsonm
   (and
    (= 1.3.0)
    :build))
  base
  (conf-tzdata :with-test)
  fmt
  (logs
   (>= 0.7.0))
  (timmy
   (= :version))))

(package
 (name timmy-lwt)
 (synopsis "Lwt utilities based on Timmy")
 (depends
  ppx_here
  (ppx_deriving
   (>= 5.0))
  (alcotest
   (and
    :with-test
    (>= 1.4.0)))
  (alcotest-lwt
   (and
    :with-test
    (>= 1.4.0)))
  (logs
   (>= 0.7.0))
  lwt
  (timmy
   (= :version)))
 (depopts js_of_ocaml-lwt))

(package
 (name timmy-timezones)
 (synopsis "Timezone database support for Timmy")
 (depends
  (timedesc (>= 3.0))
  ppx_here
  (ppx_deriving
   (>= 5.0))
  (alcotest
   (and
    :with-test
    (>= 1.4.0)))
  (logs
   (>= 0.7.0))
  (timmy
   (= :version)))
 (depopts js_of_ocaml-lwt))

; Timmy-js won't build on OCaml-CI as schematic is not available.
; (package
;  (name timmy-js)
;  (synopsis "Javascript binding of Timmy")
;  (depends
;   (conf-tzdata :with-test)
;   (schematic-jsoo
;    (and
;     (>= 0.18.2)
;     (< 0.19.0)))
;   (timmy-jsoo
;    (= :version))))
