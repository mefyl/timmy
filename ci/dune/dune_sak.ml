open Base
open Result

let ( let* ) = Result.( >>= )
let ( let+ ) = Option.( >>| )

let parse path =
  Stdio.In_channel.with_file path ~f:(fun input ->
      let lexbuf = Lexing.from_channel input in
      OpamParser.FullPos.main OpamLexer.token lexbuf path)

let pp_file = OpamPrinter.FullPos.format_opamfile

let path =
  let realpath path =
    let open Stdlib.Filename in
    if is_relative path then concat (Stdlib.Sys.getcwd ()) path else path
  in
  Cmdliner.Arg.conv (Fn.compose Result.return realpath, Fmt.string)

let input = Cmdliner.Arg.(opt (some path) None & info [ "i"; "input" ])

let toolchain =
  Cmdliner.Arg.(
    opt (some string) None
    & info ~doc:"Cross compilation toolchain" [ "toolchain" ])

let local =
  Cmdliner.Arg.(
    opt (list string) [] & info ~doc:"Routine local packages" [ "local" ])

let repo_name = Cmdliner.Arg.(opt (some string) None & info [ "n"; "name" ])
let cross_both = Cmdliner.Arg.(opt (list string) [] & info [ "cross-both" ])

let cross_exclude =
  Cmdliner.Arg.(opt (list string) [] & info [ "cross-exclude" ])

let cross_only = Cmdliner.Arg.(opt (list string) [] & info [ "cross" ])

let pp_pos fmt
    {
      OpamParserTypes.FullPos.filename;
      start = start_line, start_col;
      stop = stop_line, stop_col;
    } =
  if start_line <> stop_line then
    Stdlib.Format.fprintf fmt "%s:%d.%d-%d.%d" filename start_line start_col
      stop_line stop_col
  else
    Stdlib.Format.fprintf fmt "%s:%d.%d-%d" filename start_line start_col
      stop_col

let run command =
  let stdout, stdin, stderr =
    Unix.open_process_args_full command.(0) command (Unix.environment ())
  in
  let () = Out_channel.close stdin in
  let output = In_channel.input_all stdout
  and error = In_channel.input_all stderr in
  match Unix.close_process_full (stdout, stdin, stderr) with
  | WEXITED 0 -> Result.Ok output
  | _ ->
    Result.fail
      (Stdlib.Format.asprintf "%a failed:@ @[%s@]"
         Fmt.(array string)
         command error)

let promote_until_clean =
  Sexp.List
    [ Atom "mode"; List [ Atom "promote"; List [ Atom "until-clean" ] ] ]

let cross_toolchains = [ "ios"; "macos"; "windows"; "android" ]

let value_filter_map name value ~f =
  match value with
  | { OpamParserTypes.FullPos.pelem = OpamParserTypes.FullPos.List elements; _ }
    as value ->
    let* pelem = List.map ~f elements.pelem |> Result.all >>| List.concat in
    Result.return
      {
        value with
        pelem = OpamParserTypes.FullPos.List { elements with pelem };
      }
  | { pos; _ } -> Result.fail (Some pos, Fmt.str {|expected a list for %S|} name)

let value_map name value ~f =
  value_filter_map name value ~f:(fun v -> f v >>| fun v -> [ v ])

let () =
  let open Cmdliner in
  let generate =
    let generate name local cross_both cross_exclude cross_only =
      let cross_enabled =
        not
          (List.is_empty cross_both
          && List.is_empty cross_exclude
          && List.is_empty cross_only
          && List.is_empty local)
      in
      let* repository, packages =
        let* description = run [| "dune"; "describe"; "opam-files" |] in
        match Sexplib.Sexp.parse description with
        | Done (List files, _) -> (
          List.map files ~f:(function
            | List [ Atom name; _ ] ->
              Result.return (String.chop_suffix_if_exists ~suffix:".opam" name)
            | sexp ->
              Result.fail
                (Stdlib.Format.asprintf
                   "dune describe opam-files yielded invalid entry:@ @[%a@]"
                   Sexplib.Sexp.pp sexp))
          |> Result.all
          >>= function
          | hd :: _ as packages -> (
            match name with
            | Some name -> Result.return (name, packages)
            | None -> Result.return (hd, packages))
          | [] -> Result.fail "dune describe opam-files yielded no entries")
        | _ ->
          Result.failf "dune describe opam-files yielded invalid sexp:@ @[%s@]"
            description
      in
      let generate package =
        let open Sexplib.Sexp in
        let opam_rule ?(source = "") suffix =
          List
            [
              Atom "rule";
              List
                [
                  Atom "target";
                  Atom (package ^ suffix ^ ".%{version:" ^ package ^ "}.opam");
                ];
              List
                [
                  Atom "deps";
                  List
                    [ Atom ":opam"; Atom (source ^ package ^ suffix ^ ".opam") ];
                ];
              List
                [
                  Atom "action";
                  List
                    [
                      Atom "with-stdout-to";
                      Atom "%{target}";
                      List
                        [
                          Atom "progn";
                          List [ Atom "cat"; Atom "%{opam}" ];
                          List
                            [
                              Atom "run";
                              Atom "git";
                              Atom "log";
                              Atom
                                ("--pretty=url { src: \
                                  \"git://git@gitlab.routine.co:routine/"
                                ^ repository
                                ^ "#%H\" }");
                              Atom "-n1";
                            ];
                        ];
                    ];
                ];
            ]
        and cross_rule toolchain =
          List
            [
              Atom "rule";
              List
                [
                  Atom "target";
                  Atom (String.concat [ package; "-"; toolchain; ".opam" ]);
                ];
              promote_until_clean;
              List
                [
                  Atom "action";
                  List
                    [
                      Atom "with-stdout-to";
                      Atom "%{target}";
                      List
                        [
                          Atom "run";
                          Atom "%{dep:../.logistic/ci/dune/dune_sak.exe}";
                          Atom ("rewrite-" ^ toolchain);
                          Atom "--input";
                          Atom ("%{dep:../" ^ package ^ ".opam}");
                          Atom "--cross";
                          Atom
                            (String.concat ~sep:","
                               (packages @ local @ cross_only));
                          Atom "--cross-both";
                          Atom (String.concat ~sep:"," cross_both);
                          Atom "--cross-exclude";
                          Atom (String.concat ~sep:"," cross_exclude);
                        ];
                    ];
                ];
            ]
        in
        let host_opam_rule = opam_rule ~source:"../" "" in
        if cross_enabled then
          host_opam_rule
          :: List.concat
               (List.map cross_toolchains ~f:(fun toolchain ->
                    [ cross_rule toolchain; opam_rule ("-" ^ toolchain) ]))
        else [ host_opam_rule ]
      in
      List.map ~f:generate packages
      |> List.concat
      |> List.iter ~f:(Stdlib.Format.printf "@[%a@]@." Sexplib.Sexp.pp_hum)
      |> Result.return
    in
    Term.(
      const generate
      $ Arg.value repo_name
      $ Arg.value local
      $ Arg.value cross_both
      $ Arg.value cross_exclude
      $ Arg.value cross_only)
    |> Cmd.(v (info ~doc:"generate dune.inc boilerplate" "generate"))
  and rewrite =
    let open OpamParserTypes.FullPos in
    let pos f ({ pelem; _ } as pos) =
      match f pelem with Some pelem -> Some { pos with pelem } | None -> None
    in
    let rewrite toolchain exclude path =
      let exclude =
        match toolchain with
        | None -> exclude
        | Some toolchain ->
          let open Sequence in
          append
            (of_list exclude
            |> map ~f:(fun package -> package ^ "-" ^ toolchain))
            (of_list exclude)
          |> to_list
      in
      let excluded = List.mem ~equal:String.equal exclude in
      let file = parse path in
      let rec rewrite_contents contents =
        List.filter_map ~f:(pos rewrite_item) contents
      and rewrite_item = function
        | Variable (({ pelem = name; _ } as name_pos), value) as item -> (
          match name with
          | "depends" ->
            let+ value = pos rewrite_depends value in
            Variable (name_pos, value)
          | "pin-depends" ->
            let+ value = pos rewrite_pin_depends value in
            Variable (name_pos, value)
          | "build" -> None
          | _ -> Some item)
        | Section section ->
          let+ section = rewrite_section section in
          Section section
      and rewrite_section = function
        | { section_kind = { pelem = "url"; _ }; _ } -> None
        | section -> Some section
      and rewrite_depends = function
        | List ({ pelem = items; _ } as value) -> (
          let f = function
            | Option ({ pelem = String name; _ }, _) as depend ->
              Option.some_if (not (excluded name)) depend
            | _ -> failwith "unrecognized depends entry"
          in
          match List.filter_map ~f:(pos f) items with
          | [] -> None
          | { pos; _ } :: _ as l ->
            let pin_depend package version =
              {
                pelem =
                  Option
                    ( { pelem = String package; pos },
                      {
                        pelem =
                          [
                            {
                              pelem =
                                Prefix_relop
                                  ( { pelem = `Eq; pos },
                                    { pelem = String version; pos } );
                              pos;
                            };
                          ];
                        pos;
                      } );
                pos;
              }
            in
            Some
              (List
                 {
                   value with
                   pelem =
                     pin_depend "ocamlformat" "0.27.0"
                     :: { pelem = String "opam-file-format"; pos }
                     :: { pelem = String "ocaml-index"; pos }
                     :: { pelem = String "sexplib"; pos }
                     :: l;
                 }))
        | _ -> failwith "pin-depends expects a list"
      and rewrite_pin_depends = function
        | List { pelem = [ { pelem = String name; _ }; _ ]; _ } as pin ->
          let name = String.lsplit2_exn ~on:'.' name |> fst in
          Option.some_if (not (excluded name)) pin
        | List ({ pelem = items; _ } as value) -> (
          let f = function
            | List { pelem = [ { pelem = String name; _ }; _ ]; _ } as pin ->
              let name = String.lsplit2_exn ~on:'.' name |> fst in
              Option.some_if (not (excluded name)) pin
            | _ -> failwith "unrecognized pin-depends entry"
          in
          match List.filter_map ~f:(pos f) items with
          | [] -> None
          | l -> Some (List { value with pelem = l }))
        | _ -> failwith "pin-depends expects a list"
      in
      Stdlib.Format.printf "@[%a@]" pp_file
        { file with file_contents = rewrite_contents file.file_contents }
      |> Result.return
    in
    Term.(
      const rewrite $ Arg.value toolchain $ Arg.value local $ Arg.required input)
    |> Cmd.(v (info ~doc:"rewrite opam file for release" "rewrite"))
  and rewrite_toolchain toolchain =
    let open OpamParserTypes.FullPos in
    let pos f ({ pelem; _ } as pos) =
      match f pelem with
      | Result.Ok pelem -> Result.return { pos with pelem }
      | Result.Error (None, msg) -> Result.Error (Some pos.pos, msg)
      | Result.Error _ as error -> error
    in
    let filter_doc_test =
      let rec filter_opt = function
        | Ident "build" | Ident "with-doc" | Ident "with-test" -> false
        | Logop ({ pelem = `And; _ }, { pelem = l; _ }, { pelem = r; _ }) ->
          filter_opt l && filter_opt r
        | Logop ({ pelem = `Or; _ }, { pelem = l; _ }, { pelem = r; _ }) ->
          filter_opt l || filter_opt r
        | _ -> true
      in
      function
      | Option (_, { pelem = options; _ }) ->
        List.map ~f:(fun { pelem; _ } -> filter_opt pelem) options
        |> List.fold ~f:( && ) ~init:true
      | _ -> true
    in
    let rewrite path cross cross_both cross_exclude =
      let package =
        String.rsplit2 ~on:'.' (Stdlib.Filename.basename path)
        |> Option.value_exn
        |> fst
      in
      let file = parse path in
      let rec rewrite_contents contents =
        List.map ~f:(pos rewrite_item) contents |> Result.all
      and rewrite_item = function
        | Variable (({ pelem = name; _ } as name_pos), value) as item -> (
          match name with
          | "build" ->
            let* build = value_map "build" ~f:(pos rewrite_command) value in
            Result.return (Variable (name_pos, build))
          | "depends" | "depopts" ->
            let* value =
              value_filter_map "depends" value
                ~f:(Fn.compose Result.return rewrite_dependency)
            in
            Result.return (Variable (name_pos, value))
          | "pin-depends" ->
            let* value =
              let rewrite_pin = function
                | { pelem = List ({ pelem = [ package; url ]; _ } as args); _ }
                  as pin ->
                  rewrite_dependency package
                  |> List.map ~f:(fun package ->
                         {
                           pin with
                           pelem = List { args with pelem = [ package; url ] };
                         })
                  |> Result.return
                | { pos; _ } ->
                  Result.fail (Some pos, "unrecognized pin_depends")
              in
              value_filter_map "pin-depends" value ~f:rewrite_pin
            in
            Result.return (Variable (name_pos, value))
          | _ -> Result.return item)
        | Section _ as section -> Result.return section
      and rewrite_dependency ({ pelem = dep; _ } as item) =
        let split_version name =
          match String.lsplit2 ~on:'.' name with
          | Some (name, version) -> (name, "." ^ version)
          | None -> (name, "")
        in
        if filter_doc_test dep then
          match dep with
          | String dependency ->
            let package, version = split_version dependency in
            if List.mem ~equal:String.equal cross_exclude package then []
            else if List.mem ~equal:String.equal cross_both package then
              [
                { item with pelem = String dependency };
                {
                  item with
                  pelem = String (package ^ "-" ^ toolchain ^ version);
                };
              ]
            else if List.mem ~equal:String.equal ("ocaml" :: cross) package then
              [
                {
                  item with
                  pelem = String (package ^ "-" ^ toolchain ^ version);
                };
              ]
            else [ item ]
          | Option (value, options) ->
            rewrite_dependency value
            |> List.map ~f:(fun value ->
                   { item with pelem = Option (value, options) })
          | _ -> [ item ]
        else []
      and rewrite_command = function
        | List
            ({
               pelem =
                 ({ pelem = String "dune"; _ } as dune)
                 :: ({ pelem = String "build"; _ } as dune_command)
                 :: tail;
               _;
             } as command) ->
          let tail =
            { pelem = String "-x"; pos = dune_command.pos }
            :: { pelem = String toolchain; pos = dune_command.pos }
            :: List.filter_map
                 ~f:(function
                   | { pelem = Ident "name"; _ } as item ->
                     Some { item with pelem = String package }
                   | { pelem; _ } as item ->
                     Option.some_if (filter_doc_test pelem) item)
                 tail
          in
          Result.return
            (List { command with pelem = dune :: dune_command :: tail })
        | List _ as command -> Result.return command
        | Option (value, options) ->
          let* value = pos rewrite_command value in
          Result.return (Option (value, options))
        | _ -> Result.fail (None, "expected a list for build command")
      in
      match rewrite_contents file.file_contents with
      | Result.Ok contents ->
        Stdlib.Format.printf "@[%a@]" pp_file
          { file with file_contents = contents }
        |> Result.return
      | Result.Error (Some pos, msg) ->
        Result.Error
          (Stdlib.Format.asprintf "%a: %s" pp_pos
             { pos with filename = path }
             msg)
      | Result.Error (None, msg) -> Result.Error msg
    in
    Term.(
      const rewrite
      $ Arg.required input
      $ Arg.value cross_only
      $ Arg.value cross_both
      $ Arg.value cross_exclude)
    |> Cmd.(
         v
           (info
              ~doc:
                (Fmt.str "rewrite Opam file to cross-compile for %s" toolchain)
              ("rewrite-" ^ toolchain)))
  in
  Cmdliner.Cmd.(
    eval_result
      (group (info "dune-sak")
         [
           generate;
           rewrite;
           rewrite_toolchain "ios";
           rewrite_toolchain "macos";
           rewrite_toolchain "windows";
           rewrite_toolchain "android";
         ]))
  |> Stdlib.exit
