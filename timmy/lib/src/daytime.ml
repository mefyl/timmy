open Base

module T = struct
  include Type.Daytime

  let sexp_of_tuple (hours, minutes, seconds) =
    let open Base.Sexp in
    List
      [
        List [ Atom "hours"; Atom (Int.to_string hours) ];
        List [ Atom "minutes"; Atom (Int.to_string minutes) ];
        List [ Atom "seconds"; Atom (Int.to_string seconds) ];
      ]

  let sexp_of_t { hours; minutes; seconds } =
    sexp_of_tuple (hours, minutes, seconds)
end

include T

let to_int { hours; minutes; seconds } =
  (hours * 60 * 60) + (minutes * 60) + seconds

let of_int s =
  let minutes = s / 60
  and seconds = Int.rem s 60 in
  let hours = minutes / 60
  and minutes = Int.rem minutes 60 in
  make ~hours ~minutes ~seconds

module O = struct
  include Comparable.Make (T)

  let ( + ) time span = to_int time + Span.to_seconds span |> of_int
end

let of_time ~timezone t =
  let (hours, minutes, seconds), _ =
    snd
    @@ Ptime.to_date_time ~tz_offset_s:(Timezone.to_gmt_offset_seconds timezone)
    @@ Time.to_ptime t
  in
  { hours; minutes; seconds }

let pp f { hours; minutes; seconds } =
  Fmt.pf f "%02i:%02i:%02i" hours minutes seconds

let pp_opt
    ?(format = `_24)
    ?(precision = `Seconds)
    ?(size = `Short)
    ()
    f
    { hours; minutes; seconds } =
  let format_hours =
    match (format, hours) with
    | `_24, _ -> hours
    | `_12, 0
    | `_12, 12 ->
      12
    | `_12, _ -> Int.rem hours 12
  in
  let () =
    match (precision, size, minutes, seconds) with
    | `Hours, _, _, _
    | `Minutes, `Short, 0, _
    | `Seconds, `Short, 0, 0 ->
      Fmt.pf f "%02i" format_hours
    | `Minutes, _, _, _
    | `Seconds, `Short, _, 0 ->
      Fmt.pf f "%02i:%02i" format_hours minutes
    | `Seconds, _, _, _ ->
      Fmt.pf f "%02i:%02i:%02i" format_hours minutes seconds
  in
  match format with
  | `_24 -> ()
  | `_12 ->
    if hours < 12 then
      Fmt.string f "AM"
    else
      Fmt.string f "PM"

include O

let to_time ~timezone date t =
  match
    Ptime.of_date_time
      (Date.to_tuple date, (to_tuple t, Timezone.to_gmt_offset_seconds timezone))
  with
  | Some time -> Time.of_ptime time
  | None -> Fmt.failwith "invalid date + daytime: %a %a" Date.pp date pp t

let of_tuple (hours, minutes, seconds) = make ~hours ~minutes ~seconds

let of_tuple_exn ~here t =
  match of_tuple t with
  | Result.Ok r -> r
  | Result.Error _ ->
    Error.raise (Error.create ~here "invalid daytime" t T.sexp_of_tuple)

let with_daytime ~timezone daytime time =
  let date = Date.of_time ~timezone time in
  Ptime.of_date_time
    ( Date.to_tuple date,
      (to_tuple daytime, Timezone.to_gmt_offset_seconds timezone) )
  |> Option.value_exn ~here:[%here]
       ~message:"invalid ptime out of Timmy.Daytime.with_daytime" ?error:None
  |> Time.of_ptime

let truncate_seconds daytime = { daytime with seconds = 0 }

let truncate_minutes daytime = { daytime with minutes = 0; seconds = 0 }

let latest = { hours = 23; minutes = 59; seconds = 59 }

let midnight = { hours = 0; minutes = 0; seconds = 0 }

let noon = { hours = 12; minutes = 0; seconds = 0 }
