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
    |> Timedesc.min_of_local_date_time_result
    |> Timedesc.Timestamp.to_float_s
    |> Float.to_int
  and offset_calendar_time_s ~date:(year, month, day)
      ~time:(hour, minute, second) =
    let timedesc =
      match
        Timedesc.make_exn ~tz:timere_tz ~year ~month ~day ~hour ~minute ~second
          ()
      with
      | exception e ->
        Exn.reraisef e
          "Error converting calendar time (%d, %d, %d) (%d, %d, %d) to timere"
          year month day hour minute second ()
      | x -> x
    in
    Timedesc.offset_from_utc timedesc
    |> Timedesc.min_of_local_date_time_result
    |> Timedesc.Timestamp.to_float_s
    |> Float.to_int
  in
  Timmy.Timezone.of_implementation ~offset_timestamp_s ~offset_calendar_time_s
    (Timedesc.Time_zone.name timere_tz)

let available_zones = Timedesc.Time_zone.available_time_zones

(** Normalize non-standard timezone names encountered in the wild to their IANA
    name. *)
let normalize_tz_name = function
  | "Indiana/Indianapolis" -> "America/Indiana/Indianapolis"
  | name -> (
    match String.chop_prefix ~prefix:"GMT" name with
    | None -> name
    | Some gmt -> "UTC" ^ gmt)

let of_string name =
  match Timedesc.Time_zone.make @@ normalize_tz_name name with
  | None ->
    let () = Logs.err (fun m -> m "unknown timezone: %S" name) in
    None
  | Some tz -> Some (of_timere tz)
