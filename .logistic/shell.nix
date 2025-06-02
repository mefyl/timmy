let
  logisticFullNixShell = import ./nix/full-nix-shell.nix;

  thisRoutineRepo = logisticFullNixShell.lib.mkRoutineRepo ./. {
    ocamlVersion = "5.3.0";
  };
in
thisRoutineRepo.devShells.${builtins.currentSystem}.default
