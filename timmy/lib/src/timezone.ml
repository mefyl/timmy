type t = {
  offset_calendar_time_s : date:int * int * int -> time:int * int * int -> int;
  offset_timestamp_s : unix_timestamp:Int64.t -> int;
}

let of_gmt_offset_seconds s =
  {
    offset_calendar_time_s = (fun ~date:_ ~time:_ -> s);
    offset_timestamp_s = (fun ~unix_timestamp:_ -> s);
  }

let of_implementation ~offset_calendar_time_s ~offset_timestamp_s =
  { offset_calendar_time_s; offset_timestamp_s }

let utc =
  {
    offset_calendar_time_s = (fun ~date:_ ~time:_ -> 0);
    offset_timestamp_s = (fun ~unix_timestamp:_ -> 0);
  }

let gmt_offset_seconds_at_datetime (tz : t) ~date ~time =
  tz.offset_calendar_time_s ~date ~time

let gmt_offset_seconds_at_time (tz : t) ptime =
  let unix_timestamp = Ptime.to_float_s ptime |> Int64.of_float in
  tz.offset_timestamp_s ~unix_timestamp
