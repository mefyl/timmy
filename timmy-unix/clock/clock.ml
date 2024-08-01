open Base
module Timmy = Timmy.Versions.V1_1

let now () = Ptime_clock.now () |> Timmy.Time.of_ptime

external offset_calendar_time_s : int * int * int -> int * int * int -> int
  = "ocaml_timmy_offset_calendar_time_s"

external offset_timestamp_s : Int64.t -> int = "ocaml_timmy_offset_timestamp_s"

external local_timezone_name : unit -> string
  = "ocaml_timmy_local_timezone_name"

let timezone_name_from_link timezone_link =
  try
    let link_target = Unix.readlink timezone_link in
    let target_parts = String.split ~on:'/' link_target |> List.rev in
    match target_parts with
    | city_name :: coutry_name :: _ -> Some (coutry_name ^ "/" ^ city_name)
    | _ -> None
  with _ -> None

let windows_timezone_mappings () =
  try
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
    let mapping_json = Ezjsonm.value_from_string Windows_timezones.v in
    mapping_json
    |> get_dict_elt "supplemental"
    |> get_dict_elt "windowsZones"
    |> get_dict_elt "mapTimezones"
    |> Ezjsonm.get_list zone_to_kv
    |> Map.of_alist_reduce (module String) ~f:Fn.const
  with exn ->
    Exn.reraise exn "timmy-unix: Error parsing the bundled 'windowsZones'"

let timezone_from_windows_name () =
  let windows_timezone = local_timezone_name () in
  let mappings = windows_timezone_mappings () in
  Map.find mappings windows_timezone

let get_timezone_name () =
  List.find_map
    ~f:(fun f -> f ())
    [
      (fun () -> Sys.getenv "TZ");
      (fun () -> timezone_name_from_link "/etc/localtime");
      timezone_from_windows_name;
    ]
  |> Option.value ~default:(local_timezone_name ())

let timezone_local =
  let offset_calendar_time_s ~date ~time = offset_calendar_time_s date time
  and offset_timestamp_s ~unix_timestamp =
    let () =
      if Int64.compare 0L unix_timestamp > 0 then
        Fmt.failwith "Given timestamp is negative"
    in
    offset_timestamp_s unix_timestamp
  in
  Timmy.Timezone.of_implementation ~offset_calendar_time_s ~offset_timestamp_s
    (get_timezone_name ())

let today () = Timmy.Date.of_time ~timezone:timezone_local @@ now ()
