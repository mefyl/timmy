(alias (name extdeps) (deps opam/timmy.opam.extdeps))
(subdir opam
 (rule (target timmy.%{version:timmy}.opam) (deps (:opam ../timmy.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy.opam.locked)
  (action (run %{bin:opam} lock timmy)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-ios.%{version:timmy}.opam) (deps (:opam timmy-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-ios)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-macos.%{version:timmy}.opam)
  (deps (:opam timmy-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-macos)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-windows.%{version:timmy}.opam)
  (deps (:opam timmy-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-windows)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows))))
 (rule (target timmy-android.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-android --input
     %{dep:../timmy.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-android.%{version:timmy}.opam)
  (deps (:opam timmy-android.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-android.opam.locked)
  (action (run %{bin:opam} lock timmy-android)))
 (rule (mode (promote (until-clean))) (target timmy.opam.extdeps-android)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-android.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain android)))))
(alias (name extdeps) (deps opam/timmy-jsoo.opam.extdeps))
(subdir opam
 (rule (target timmy-jsoo.%{version:timmy-jsoo}.opam)
  (deps (:opam ../timmy-jsoo.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-jsoo.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo)))
 (rule (mode (promote (until-clean))) (target timmy-jsoo.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-jsoo-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy-jsoo.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-jsoo-ios.%{version:timmy-jsoo}.opam)
  (deps (:opam timmy-jsoo-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-jsoo-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo-ios)))
 (rule (mode (promote (until-clean))) (target timmy-jsoo.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-jsoo-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy-jsoo.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-jsoo-macos.%{version:timmy-jsoo}.opam)
  (deps (:opam timmy-jsoo-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-jsoo-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo-macos)))
 (rule (mode (promote (until-clean))) (target timmy-jsoo.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-jsoo-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy-jsoo.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-jsoo-windows.%{version:timmy-jsoo}.opam)
  (deps (:opam timmy-jsoo-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-jsoo-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo-windows)))
 (rule (mode (promote (until-clean)))
  (target timmy-jsoo.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows))))
 (rule (target timmy-jsoo-android.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-android --input
     %{dep:../timmy-jsoo.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-jsoo-android.%{version:timmy-jsoo}.opam)
  (deps (:opam timmy-jsoo-android.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-jsoo-android.opam.locked)
  (action (run %{bin:opam} lock timmy-jsoo-android)))
 (rule (mode (promote (until-clean)))
  (target timmy-jsoo.opam.extdeps-android)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-jsoo-android.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain android)))))
(alias (name extdeps) (deps opam/timmy-lwt.opam.extdeps))
(subdir opam
 (rule (target timmy-lwt.%{version:timmy-lwt}.opam)
  (deps (:opam ../timmy-lwt.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-lwt.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-lwt-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy-lwt.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-lwt-ios.%{version:timmy-lwt}.opam)
  (deps (:opam timmy-lwt-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-lwt-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt-ios)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-lwt-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy-lwt.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-lwt-macos.%{version:timmy-lwt}.opam)
  (deps (:opam timmy-lwt-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-lwt-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt-macos)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-lwt-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy-lwt.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-lwt-windows.%{version:timmy-lwt}.opam)
  (deps (:opam timmy-lwt-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-lwt-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt-windows)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows))))
 (rule (target timmy-lwt-android.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-android --input
     %{dep:../timmy-lwt.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-lwt-android.%{version:timmy-lwt}.opam)
  (deps (:opam timmy-lwt-android.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-lwt-android.opam.locked)
  (action (run %{bin:opam} lock timmy-lwt-android)))
 (rule (mode (promote (until-clean))) (target timmy-lwt.opam.extdeps-android)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-lwt-android.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain android)))))
(alias (name extdeps) (deps opam/timmy-timezones.opam.extdeps))
(subdir opam
 (rule (target timmy-timezones.%{version:timmy-timezones}.opam)
  (deps (:opam ../timmy-timezones.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-timezones.opam.locked)
  (action (run %{bin:opam} lock timmy-timezones)))
 (rule (mode (promote (until-clean))) (target timmy-timezones.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-timezones.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-timezones-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy-timezones.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-timezones-ios.%{version:timmy-timezones}.opam)
  (deps (:opam timmy-timezones-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-timezones-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-timezones-ios)))
 (rule (mode (promote (until-clean)))
  (target timmy-timezones.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-timezones-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-timezones-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy-timezones.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-timezones-macos.%{version:timmy-timezones}.opam)
  (deps (:opam timmy-timezones-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-timezones-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-timezones-macos)))
 (rule (mode (promote (until-clean)))
  (target timmy-timezones.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-timezones-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-timezones-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy-timezones.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-timezones-windows.%{version:timmy-timezones}.opam)
  (deps (:opam timmy-timezones-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-timezones-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-timezones-windows)))
 (rule (mode (promote (until-clean)))
  (target timmy-timezones.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-timezones-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows))))
 (rule (target timmy-timezones-android.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-android --input
     %{dep:../timmy-timezones.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-timezones-android.%{version:timmy-timezones}.opam)
  (deps (:opam timmy-timezones-android.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-timezones-android.opam.locked)
  (action (run %{bin:opam} lock timmy-timezones-android)))
 (rule (mode (promote (until-clean)))
  (target timmy-timezones.opam.extdeps-android)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-timezones-android.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain android)))))
(alias (name extdeps) (deps opam/timmy-unix.opam.extdeps))
(subdir opam
 (rule (target timmy-unix.%{version:timmy-unix}.opam)
  (deps (:opam ../timmy-unix.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-unix.opam.locked)
  (action (run %{bin:opam} lock timmy-unix)))
 (rule (mode (promote (until-clean))) (target timmy-unix.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo))))
 (rule (target timmy-unix-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../timmy-unix.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-unix-ios.%{version:timmy-unix}.opam)
  (deps (:opam timmy-unix-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-unix-ios.opam.locked)
  (action (run %{bin:opam} lock timmy-unix-ios)))
 (rule (mode (promote (until-clean))) (target timmy-unix.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix-ios.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain ios))))
 (rule (target timmy-unix-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../timmy-unix.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-unix-macos.%{version:timmy-unix}.opam)
  (deps (:opam timmy-unix-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-unix-macos.opam.locked)
  (action (run %{bin:opam} lock timmy-unix-macos)))
 (rule (mode (promote (until-clean))) (target timmy-unix.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix-macos.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain macos))))
 (rule (target timmy-unix-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../timmy-unix.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-unix-windows.%{version:timmy-unix}.opam)
  (deps (:opam timmy-unix-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-unix-windows.opam.locked)
  (action (run %{bin:opam} lock timmy-unix-windows)))
 (rule (mode (promote (until-clean)))
  (target timmy-unix.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix-windows.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain windows))))
 (rule (target timmy-unix-android.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-android --input
     %{dep:../timmy-unix.opam} --cross
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo,base,fmt,lwt,ptime,timedesc
     --cross-both timmy,ppx_here,ppx_deriving --cross-exclude js_of_ocaml))))
 (rule (target timmy-unix-android.%{version:timmy-unix}.opam)
  (deps (:opam timmy-unix-android.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (run git log
      "--pretty=url { src: \"git://git@gitlab.routine.co:routine/timmy#%H\" }"
      -n1)))))
 (rule (deps (universe)) (target timmy-unix-android.opam.locked)
  (action (run %{bin:opam} lock timmy-unix-android)))
 (rule (mode (promote (until-clean)))
  (target timmy-unix.opam.extdeps-android)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:timmy-unix-android.opam.locked} --local
     timmy,timmy-jsoo,timmy-lwt,timmy-timezones,timmy-unix,hlist,schematic,schematic-jsoo
     --toolchain android)))))
