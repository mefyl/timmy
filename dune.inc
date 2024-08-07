(alias (name extdeps) (deps opam/timmy.opam.extdeps))
(subdir opam
 (rule (target timmy.%{version:timmy}.opam) (mode (promote (until-clean)))
  (deps (:opam timmy.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy}\" }")))))
 (rule (deps (universe)) (target timmy.opam.locked)
  (action (run %{bin:opam} lock timmy)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-ios.%{version:timmy}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy}\" }")))))
 (rule (deps (universe)) (target timmy-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-ios)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-macos.%{version:timmy}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy}\" }")))))
 (rule (deps (universe)) (target timmy-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-macos)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-windows.%{version:timmy}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy}\" }")))))
 (rule (deps (universe)) (target timmy-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-windows)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows)))))
(alias (name extdeps) (deps opam/timmy-jsoo.opam.extdeps))
(subdir opam
 (rule (target timmy-jsoo.%{version:timmy-jsoo}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-jsoo.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-jsoo}\" }")))))
 (rule (deps (universe)) (target timmy-jsoo.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo)))
 (rule (mode (promote (until-clean))) (target timmy-jsoo.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-jsoo-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy-jsoo.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-jsoo-ios.%{version:timmy-jsoo}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-jsoo-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-jsoo}\" }")))))
 (rule (deps (universe)) (target timmy-jsoo-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo-ios)))
 (rule (mode (promote (until-clean))) (target timmy-jsoo.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-jsoo-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy-jsoo.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-jsoo-macos.%{version:timmy-jsoo}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-jsoo-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-jsoo}\" }")))))
 (rule (deps (universe)) (target timmy-jsoo-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo-macos)))
 (rule (mode (promote (until-clean))) (target timmy-jsoo.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-jsoo-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy-jsoo.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-jsoo-windows.%{version:timmy-jsoo}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-jsoo-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-jsoo}\" }")))))
 (rule (deps (universe)) (target timmy-jsoo-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo-windows)))
 (rule (mode (promote (until-clean)))
  (target timmy-jsoo.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows)))))
(alias (name extdeps) (deps opam/timmy-lwt.opam.extdeps))
(subdir opam
 (rule (target timmy-lwt.%{version:timmy-lwt}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-lwt.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-lwt}\" }")))))
 (rule (deps (universe)) (target timmy-lwt.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-lwt-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy-lwt.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-lwt-ios.%{version:timmy-lwt}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-lwt-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-lwt}\" }")))))
 (rule (deps (universe)) (target timmy-lwt-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt-ios)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-lwt-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy-lwt.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-lwt-macos.%{version:timmy-lwt}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-lwt-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-lwt}\" }")))))
 (rule (deps (universe)) (target timmy-lwt-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt-macos)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-lwt-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy-lwt.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-lwt-windows.%{version:timmy-lwt}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-lwt-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-lwt}\" }")))))
 (rule (deps (universe)) (target timmy-lwt-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt-windows)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows)))))
(alias (name extdeps) (deps opam/timmy-unix.opam.extdeps))
(subdir opam
 (rule (target timmy-unix.%{version:timmy-unix}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-unix.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-unix}\" }")))))
 (rule (deps (universe)) (target timmy-unix.opam.locked)
  (action (run %{bin:opam} lock timmy-unix)))
 (rule (mode (promote (until-clean))) (target timmy-unix.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-unix-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy-unix.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-unix-ios.%{version:timmy-unix}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-unix-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-unix}\" }")))))
 (rule (deps (universe)) (target timmy-unix-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-unix-ios)))
 (rule (mode (promote (until-clean))) (target timmy-unix.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-unix-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy-unix.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-unix-macos.%{version:timmy-unix}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-unix-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-unix}\" }")))))
 (rule (deps (universe)) (target timmy-unix-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-unix-macos)))
 (rule (mode (promote (until-clean))) (target timmy-unix.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-unix-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy-unix.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-unix-windows.%{version:timmy-unix}.opam)
  (mode (promote (until-clean))) (deps (:opam timmy-unix-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/timmy#%{version:timmy-unix}\" }")))))
 (rule (deps (universe)) (target timmy-unix-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-unix-windows)))
 (rule (mode (promote (until-clean)))
  (target timmy-unix.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows)))))
