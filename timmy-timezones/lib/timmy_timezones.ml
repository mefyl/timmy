open! Base

let of_timere timere_tz : Timmy.Timezone.t =
  let offset_timestamp_s ~unix_timestamp =
    let timedesc =
      match
        Timedesc.of_timestamp_exn ~tz_of_date_time:timere_tz
          (Timedesc.Timestamp.of_float_s (Int64.to_float unix_timestamp))
      with
      | exception e ->
        Exn.reraisef e "Error converting timestamp %Ld to timere" unix_timestamp
          ()
      | x -> x
    in
    Timedesc.offset_from_utc timedesc
    |> Timedesc.min_of_local_date_time_result |> Timedesc.Timestamp.to_float_s
    |> Float.to_int
  and offset_calendar_time_s ~date:(year, month, day)
      ~time:(hour, minute, second) =
    let timedesc =
      match Timedesc.make_exn ~year ~month ~day ~hour ~minute ~second () with
      | exception e ->
        Exn.reraisef e
          "Error converting calendar time (%d, %d, %d) (%d, %d, %d) to timere"
          year month day hour minute second ()
      | x -> x
    in
    Timedesc.offset_from_utc timedesc
    |> Timedesc.min_of_local_date_time_result |> Timedesc.Timestamp.to_float_s
    |> Float.to_int
  in
  Timmy.Timezone.of_implementation ~offset_timestamp_s ~offset_calendar_time_s
    (Timedesc.Time_zone.name timere_tz)

let available_zones = Timedesc.Time_zone.available_time_zones

let of_string tz_name =
  let tz = Timedesc.Time_zone.make tz_name in
  Option.map ~f:of_timere tz
