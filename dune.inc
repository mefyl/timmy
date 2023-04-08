(rule (target timmy.%{version:timmy}.opam) (deps (:opam timmy.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy}\" }")))))
(rule (target timmy-ios.opam)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
    %{dep:timmy.opam} --cross
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
    --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
(rule (target timmy-ios.%{version:timmy}.opam) (deps (:opam timmy-ios.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy}\" }")))))
(rule (deps (universe)) (target timmy.opam.locked)
 (action (run %{bin:opam} lock timmy)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target timmy.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:timmy.opam.locked} --local
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
(rule (target timmy-jsoo.%{version:timmy-jsoo}.opam)
 (deps (:opam timmy-jsoo.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-jsoo}\" }")))))
(rule (target timmy-jsoo-ios.opam)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
    %{dep:timmy-jsoo.opam} --cross
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
    --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
(rule (target timmy-jsoo-ios.%{version:timmy-jsoo}.opam)
 (deps (:opam timmy-jsoo-ios.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-jsoo}\" }")))))
(rule (deps (universe)) (target timmy-jsoo.opam.locked)
 (action (run %{bin:opam} lock timmy-jsoo)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target timmy-jsoo.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:timmy-jsoo.opam.locked} --local
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
(rule (target timmy-lwt.%{version:timmy-lwt}.opam)
 (deps (:opam timmy-lwt.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-lwt}\" }")))))
(rule (target timmy-lwt-ios.opam)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
    %{dep:timmy-lwt.opam} --cross
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
    --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
(rule (target timmy-lwt-ios.%{version:timmy-lwt}.opam)
 (deps (:opam timmy-lwt-ios.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-lwt}\" }")))))
(rule (deps (universe)) (target timmy-lwt.opam.locked)
 (action (run %{bin:opam} lock timmy-lwt)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target timmy-lwt.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:timmy-lwt.opam.locked} --local
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
(rule (target timmy-unix.%{version:timmy-unix}.opam)
 (deps (:opam timmy-unix.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-unix}\" }")))))
(rule (target timmy-unix-ios.opam)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
    %{dep:timmy-unix.opam} --cross
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
    --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
(rule (target timmy-unix-ios.%{version:timmy-unix}.opam)
 (deps (:opam timmy-unix-ios.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-unix}\" }")))))
(rule (deps (universe)) (target timmy-unix.opam.locked)
 (action (run %{bin:opam} lock timmy-unix)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target timmy-unix.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:timmy-unix.opam.locked} --local
    timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
