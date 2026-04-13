open Base

type pin = {
  url : string;
  packages : (string * string) list;
}

let parse_pin = function
  | Sexplib.Sexp.List (Atom "pin" :: fields) -> (
    let url =
      List.find_map fields ~f:(function
        | Sexplib.Sexp.List [ Atom "url"; Atom u ] -> Some u
        | _ -> None)
    in
    let packages =
      List.filter_map fields ~f:(function
        | Sexplib.Sexp.List (Atom "package" :: pkg_fields) -> (
          let find_value key =
            List.find_map pkg_fields ~f:(function
              | Sexplib.Sexp.List [ Atom k; Atom v ] when String.equal k key ->
                Some v
              | _ -> None)
          in
          match (find_value "name", find_value "version") with
          | Some name, Some version -> Some (name, version)
          | _ -> None)
        | _ -> None)
    in
    match (url, packages) with
    | Some url, _ :: _ -> Some { url; packages }
    | _ -> None)
  | _ -> None

let run path =
  let sexps = Sexplib.Sexp.load_sexps path in
  let pins = List.filter_map sexps ~f:parse_pin in
  if not (List.is_empty pins) then begin
    Stdio.print_string "pin-depends: [\n";
    List.iter pins ~f:(fun { url; packages } ->
        List.iter packages ~f:(fun (name, version) ->
            Stdio.printf "  [\"%s.%s\" \"%s\"]\n" name version url));
    Stdio.print_string "]\n"
  end

let () =
  let open Cmdliner in
  let path_arg =
    Arg.(
      value
      & pos 0 string "dune-project"
      & info [] ~docv:"DUNE_PROJECT"
          ~doc:"Path to the dune-project file to extract pins from.")
  in
  let cmd =
    Cmd.(
      v
        (info "opam-pins"
           ~doc:
             "Generate an opam pin-depends template from dune-project pin \
              stanzas.")
        Term.(const run $ path_arg))
  in
  Stdlib.exit (Cmd.eval cmd)
