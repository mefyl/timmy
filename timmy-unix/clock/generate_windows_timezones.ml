open Base

let () =
  try
    let mapping =
      let get_dict_elt key json =
        Map.find_exn
          (Ezjsonm.get_dict json |> Map.of_alist_exn (module String))
          key
      in
      let zone_to_kv zone =
        let map_zone = get_dict_elt "mapZone" zone in
        ( get_dict_elt "_other" map_zone |> Ezjsonm.get_string,
          get_dict_elt "_type" map_zone |> Ezjsonm.get_string )
      in
      Ezjsonm.value_from_channel Stdlib.In_channel.stdin
      |> get_dict_elt "supplemental"
      |> get_dict_elt "windowsZones"
      |> get_dict_elt "mapTimezones"
      |> Ezjsonm.get_list zone_to_kv
    in
    Fmt.(
      pr "@[<v>@[<v 2>let v = [@,@[<v>%a@]@]@,]@]"
      @@ list ~sep:semi
      @@ const char '('
         ++ (box @@ pair ~sep:comma Dump.string Dump.string)
         ++ const char ')')
      mapping
  with exn ->
    Exn.reraise exn "timmy-unix: Error parsing the bundled 'windowsZones'"
