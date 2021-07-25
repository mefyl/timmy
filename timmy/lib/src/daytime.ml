open Acid

module T = struct
  type t = {
    hours : int;
    minutes : int;
    seconds : int;
  }
  [@@deriving ord]

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

let make ~hours ~minutes ~seconds =
  let open Let.Syntax2 (Result) in
  let+ () =
    if hours >= 0 && hours < 24 then
      Result.return ()
    else
      Result.failf "invalid hours: %i" hours
  and+ () =
    if minutes >= 0 && minutes < 60 then
      Result.return ()
    else
      Result.failf "invalid minutes: %i" hours
  and+ () =
    if seconds >= 0 && seconds < 60 then
      Result.return ()
    else
      Result.failf "invalid seconds: %i" hours
  in
  { hours; minutes; seconds }

module O = struct
  include Comparable.Make (T)
end

include O

let of_time ~timezone t =
  let (hours, minutes, seconds), _ =
    snd
    @@ Ptime.to_date_time ~tz_offset_s:(Timezone.to_gmt_offset_seconds timezone)
    @@ Time.to_ptime t
  in
  { hours; minutes; seconds }

let pp f { hours; minutes; seconds } =
  Fmt.pf f "%02i:%02i:%02i" hours minutes seconds

let to_tuple { hours; minutes; seconds } = (hours, minutes, seconds)

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

let latest = { hours = 23; minutes = 59; seconds = 59 }

let midnight = { hours = 0; minutes = 0; seconds = 0 }

let noon = { hours = 12; minutes = 0; seconds = 0 }
