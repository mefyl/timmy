let now () = Ptime_clock.now () |> Timmy.Time.of_ptime

external offset_calendar_time_s : int * int * int -> int * int * int -> int
  = "ocaml_timmy_offset_calendar_time_s"

external offset_timestamp_s : Int64.t -> int = "ocaml_timmy_offset_timestamp_s"

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

let today () = Timmy.Date.of_time ~timezone:timezone_local @@ now ()
