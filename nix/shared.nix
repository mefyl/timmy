{ pkgs }:
{
  routine_run = pkgs.buildFHSEnv {
    name = "routine-run";

    targetPkgs = pkgs:
      (pkgs.appimageTools.defaultFhsEnvArgs.targetPkgs pkgs) ++
      (pkgs.appimageTools.defaultFhsEnvArgs.multiPkgs pkgs);

    runScript = pkgs.writers.writeBash "routine-run" ''
      executable="''${1:-./dist_electron/linux-unpacked/routine}"
      shift

      exec "$executable" "$@"
    '';

  };
  ocamlformatVersionFromDotOcamlformat = path:
    builtins.elemAt
      (builtins.match ".*(\n|^)version=([^\n]*).*"
        (builtins.readFile
          path)) 1;
}
