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
  (odoc :with-doc))
 (depopts schematic)
 (conflicts
  (schematic
   (or
    (< 0.18.2)
    (= 0.20.0)
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
   (= :version))))

(package
 (name timmy-timezones)
 (synopsis "Timezone database support for Timmy")
 (depends
  (timedesc
   (>= 3.0))
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
   (= :version))
  (timmy-unix
   (and
    :with-test
    (= :version)))))
