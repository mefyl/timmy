(rule (deps (universe)) (target timmy.opam.locked)
 (action (run %{bin:opam} lock timmy)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target timmy.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:timmy.opam.locked} --exclude
    timmy,timmy-jsoo,schematic,schematic-jsoo))))
(rule (deps (universe)) (target timmy-jsoo.opam.locked)
 (action (run %{bin:opam} lock timmy-jsoo)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target timmy-jsoo.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:timmy-jsoo.opam.locked} --exclude
    timmy,timmy-jsoo,schematic,schematic-jsoo))))
