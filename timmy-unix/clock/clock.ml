open Base
module Timmy = Timmy.Versions.V1_1

let now () = Ptime_clock.now () |> Timmy.Time.of_ptime

external offset_calendar_time_s :
  int * int * int -> int * int * int -> int option
  = "ocaml_timmy_offset_calendar_time_s"

external offset_timestamp_s : Int64.t -> int option
  = "ocaml_timmy_offset_timestamp_s"

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
  Map.of_alist_reduce (module String) ~f:Fn.const Windows_timezones.v

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
  let offset_calendar_time_s ~date ~time =
    match offset_calendar_time_s date time with
    | Some offset -> offset
    | None ->
      let () =
        let (year, month, day), (hours, minutes, seconds) = (date, time) in
        Logs.warn (fun m ->
            m
              "determining timezone offset of %04d-%02d-%02d %02d:%02d:%02d \
               not supported on this platform, assuming an offset of [0]"
              year month day hours minutes seconds)
      in
      0
  and timezone_name = get_timezone_name () in
  let offset_timestamp_s ~unix_timestamp =
    match offset_timestamp_s unix_timestamp with
    | Some offset -> offset
    | None when Int64.compare 0L unix_timestamp > 0 ->
      let () =
        Logs.warn (fun m ->
            m
              "passing a negative timestamp %a to gmt_offset_seconds_at_time \
               not supported on this platform, assuming an offset of 0"
              Int64.pp unix_timestamp)
      in
      0
    | None ->
      Fmt.failwith "Unknown error converting the timestamp %a to a local time"
        Int64.pp unix_timestamp
  in
  Timmy.Timezone.of_implementation ~offset_calendar_time_s ~offset_timestamp_s
    timezone_name

let today () = Timmy.Date.of_time ~timezone:timezone_local @@ now ()
