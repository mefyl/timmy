open Base
open Result

let ( let* ) = Result.( >>= )
let ( let+ ) = Option.( >>| )

let parse path =
  Stdio.In_channel.with_file path ~f:(fun input ->
      let lexbuf = Lexing.from_channel input in
      OpamParser.FullPos.main OpamLexer.token lexbuf path)

let pp_file = OpamPrinter.FullPos.format_opamfile
let input = Cmdliner.Arg.(opt (some string) None & info [ "i"; "input" ])
let exclude = Cmdliner.Arg.(opt (list string) [] & info [ "e"; "exclude" ])

let () =
  let open Cmdliner in
  let generate =
    let generate exclude =
      let* repository, packages =
        let (status, stdout), stderr =
          Shexp_process.(
            run_exit_status "dune" [ "describe"; "opam-files" ]
            |> capture [ Stdout ] |> capture [ Stderr ] |> eval)
        in
        match status with
        | Exited 0 -> (
          match Sexplib.Sexp.parse stdout with
          | Done (List files, _) -> (
            List.map files ~f:(function
              | List [ Atom name; _ ] ->
                Result.return
                  (String.chop_suffix_if_exists ~suffix:".opam" name)
              | sexp ->
                Result.fail
                  (Caml.Format.asprintf
                     "dune describe opam-files yielded invalid entry:@ @[%a@]"
                     Sexplib.Sexp.pp sexp))
            |> Result.all
            >>= function
            | hd :: _ as packages -> Result.return (hd, packages)
            | [] -> Result.fail "dune describe opam-files yielded no entries")
          | _ ->
            Result.fail
              (Caml.Format.asprintf
                 "dune describe opam-files yielded invalid sexp:@ @[%s@]" stdout)
          )
        | _ ->
          Result.fail
            (Caml.Format.asprintf "dune describe opam-files failed:@ @[%s@]"
               stderr)
      in
      let generate package =
        let open Sexplib.Sexp in
        let opam_rule =
          List
            [
              Atom "rule";
              List
                [
                  Atom "target";
                  Atom (package ^ ".%{version:" ^ package ^ "}.opam");
                ];
              List
                [ Atom "deps"; List [ Atom ":opam"; Atom (package ^ ".opam") ] ];
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
                              Atom "echo";
                              Atom
                                ("url { src: \
                                  \"git://git@gitlab.routine.co:routine/"
                               ^ repository ^ "#%{version:" ^ package ^ "}\" }"
                                );
                            ];
                        ];
                    ];
                ];
            ]
        and locked_rule =
          List
            [
              Atom "rule";
              List [ Atom "deps"; List [ Atom "universe" ] ];
              List [ Atom "target"; Atom (package ^ ".opam.locked") ];
              List
                [
                  Atom "action";
                  List
                    [
                      Atom "run"; Atom "%{bin:opam}"; Atom "lock"; Atom package;
                    ];
                ];
            ]
        and extdeps_rule =
          List
            [
              Atom "rule";
              List [ Atom "alias"; Atom "extdeps" ];
              List
                [
                  Atom "mode";
                  List [ Atom "promote"; List [ Atom "until-clean" ] ];
                ];
              List [ Atom "target"; Atom (package ^ ".opam.extdeps") ];
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
                          Atom "%{dep:.logistic/dune/extdeps/extdeps.exe}";
                          Atom "rewrite";
                          Atom "--input";
                          Atom ("%{dep:" ^ package ^ ".opam.locked}");
                          Atom "--exclude";
                          Atom (String.concat ~sep:"," (packages @ exclude));
                        ];
                    ];
                ];
            ]
        in
        [ opam_rule; locked_rule; extdeps_rule ]
      in
      List.map ~f:generate packages
      |> List.concat
      |> List.iter ~f:(Caml.Format.printf "@[%a@]@." Sexplib.Sexp.pp_hum)
      |> Result.return
    in
    Term.(const generate $ Arg.value exclude) |> Cmd.(v (info "generate"))
  and rewrite =
    let open OpamParserTypes.FullPos in
    let pos f ({ pelem; _ } as pos) =
      match f pelem with Some pelem -> Some { pos with pelem } | None -> None
    in
    let rewrite exclude path =
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
                 { value with pelem = pin_depend "ocamlformat" "0.24.1" :: l }))
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
      Caml.Format.printf "@[%a@]" pp_file
        { file with file_contents = rewrite_contents file.file_contents }
      |> Result.return
    in
    Term.(const rewrite $ Arg.value exclude $ Arg.required input)
    |> Cmd.(v (info "rewrite"))
  in
  Cmdliner.Cmd.(eval_result (group (info "extdeps") [ generate; rewrite ]))
  |> Caml.exit
