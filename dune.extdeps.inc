(rule (target timmy.%{version:timmy}.opam) (deps (:opam timmy.opam))
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
    %{dep:timmy.opam.locked} --exclude
    timmy,timmy-jsoo,timmy-unix,schematic,schematic-jsoo))))
(rule (target timmy-jsoo.%{version:timmy-jsoo}.opam)
 (deps (:opam timmy-jsoo.opam))
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
    %{dep:timmy-jsoo.opam.locked} --exclude
    timmy,timmy-jsoo,timmy-unix,schematic,schematic-jsoo))))
(rule (target timmy-unix.%{version:timmy-unix}.opam)
 (deps (:opam timmy-unix.opam))
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
    %{dep:timmy-unix.opam.locked} --exclude
    timmy,timmy-jsoo,timmy-unix,schematic,schematic-jsoo))))
