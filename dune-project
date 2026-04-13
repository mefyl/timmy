(lang dune 3.20)

(name timmy)

(version 1.2.4)

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
    (< 0.21.2)
    (>= 0.23.0)))))

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
    (>= 0.23.0)))))

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
  (lwt
   (and
    (>= 6.0.0)
    (< 7.0.0)))
  (timmy
   (= :version)))
 (depopts js_of_ocaml-lwt))

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
    (= :version)))
  (wasm_of_ocaml-compiler :with-test)))

; For Wasmoo support.

(pin
 (url
  git+https://github.com/mefyl/alcotest#f0007cbfdffd868945dd7503160c8bce08d01113)
 (package
  (name alcotest)
  (version 1.9.1)))

; Work around a concurrency bug with ocamlfind + dune pkg until it's fixed
; upstream.

; File "dune.lock/bytesrw.0.3.0.pkg", line 8, characters 6-11:
; 8 |       ocaml
;           ^^^^^
; Error: Logs for package bytesrw
; Warning: The library directory where ocamlbuild was originally installed (/builds/routine/schematic/_build/.sandbox/a085ee08f9d502a0339365e7db1f402b/_private/default/.pkg/ocamlbuild.0.16.1+dune-6439ba2990d98dd44846aa8272d56e5b/target/lib/ocamlbuild) either no longer exists, or does not contain a copy of the ocamlbuild library. Guessing that the correct library directory is /builds/routine/schematic/_build/_private/default/.pkg/ocamlbuild.0.16.1+dune-6439ba2990d98dd44846aa8272d56e5b/target/lib/ocamlbuild because a copy of the ocamlbuild library exists at that location, and because it is located at the expected path relative to the current ocamlbuild executable. This can happen if ocamlbuild's files are moved from the location where they were originally installed.pkg.ml: [ERROR] cmd ['ocamlbuild' '-use-ocamlfind' '-classic-display' '-j' '4' '-tag' 'debug'
;      '-build-dir' '_build' 'pkg.otarget']: exited with 10

(pin
 (url
  git+https://github.com/dbuenzli/bytesrw#47bdebcbc527c264572fb5fbcc5ca606e67bcd32)
 (package
  (name bytesrw)
  (version 0.3.0)))
