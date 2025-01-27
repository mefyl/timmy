type t = {
  name : string;
  offset_calendar_time_s : date:int * int * int -> time:int * int * int -> int;
  offset_timestamp_s : unix_timestamp:Int64.t -> int;
}

let of_gmt_offset_seconds s =
  let name =
    if s = 0 then "UTC"
    else
      let minutes = abs (s / 60) in
      let hours = minutes / 60
      and minutes = minutes mod 60 in
      Fmt.str "UTC%c%02d:%02d" (if s > 0 then '+' else '-') hours minutes
  in
  {
    name;
    offset_calendar_time_s = (fun ~date:_ ~time:_ -> s);
    offset_timestamp_s = (fun ~unix_timestamp:_ -> s);
  }

let of_implementation ~offset_calendar_time_s ~offset_timestamp_s name =
  { name; offset_calendar_time_s; offset_timestamp_s }

let utc =
  {
    name = "UTC";
    offset_calendar_time_s = (fun ~date:_ ~time:_ -> 0);
    offset_timestamp_s = (fun ~unix_timestamp:_ -> 0);
  }

let gmt_offset_seconds_at_datetime (tz : t) ~date ~time =
  tz.offset_calendar_time_s ~date ~time

let gmt_offset_seconds_at_time (tz : t) ptime =
  let unix_timestamp = Ptime.to_float_s ptime |> Int64.of_float in
  tz.offset_timestamp_s ~unix_timestamp

let name = function
  | { name = ""; _ } ->
    failwith
      "it appears you mixed a pre 1.0 Clock implementation with a post 1.1 \
       Timmy interface"
  | { name; _ } -> name

module T = struct
  type nonrec t = t

  let compare t1 t2 = String.compare (name t1) (name t2)
  let sexp_of_t t = Base.Sexp.Atom (name t)
end

include Base.Comparable.Make (T)

let pp fmt t = Fmt.string fmt @@ name t
