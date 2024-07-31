module Timmy = Timmy.Versions.V1_1

let now () = Ptime_clock.now () |> Timmy.Time.of_ptime

external offset_calendar_time_s : int * int * int -> int * int * int -> int
  = "ocaml_timmy_offset_calendar_time_s"

external offset_timestamp_s : Int64.t -> int = "ocaml_timmy_offset_timestamp_s"

external local_timezone_name : unit -> string
  = "ocaml_timmy_local_timezone_name"

external set_install : string -> unit = "ocaml_timmy_set_install"

let find_tzdata () =
  let data_dirs = Timmy_unix_sites.Sites.data in
  data_dirs
  |> List.find_map (fun dir ->
         let tzdata = Filename.concat dir "tzdata" in
         if Sys.file_exists tzdata then Some tzdata else None)

let set_tzdata_location () =
  match find_tzdata () with
  | Some data -> set_install data
  | None -> failwith "Couldn't find the tzdata database"

let timezone_local =
  let offset_calendar_time_s ~date ~time =
    set_tzdata_location ();
    offset_calendar_time_s date time
  and offset_timestamp_s ~unix_timestamp =
    let () =
      if Int64.compare 0L unix_timestamp > 0 then
        Fmt.failwith "Given timestamp is negative"
    in
    set_tzdata_location ();
    offset_timestamp_s unix_timestamp
  in
  Timmy.Timezone.of_implementation ~offset_calendar_time_s ~offset_timestamp_s
    (local_timezone_name ())

let today () = Timmy.Date.of_time ~timezone:timezone_local @@ now ()
