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

let get_timezone_name () =
  List.find_map
    ~f:(fun f -> f ())
    [
      (fun () -> Sys.getenv "TZ");
      (fun () -> timezone_name_from_link "/etc/localtime");
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
