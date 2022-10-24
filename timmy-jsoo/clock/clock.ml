include Timmy.Timezone
module Js = Js_of_ocaml.Js

let now () = Ptime_clock.now () |> Timmy.Time.of_ptime

(* JS Date's getTimezoneOffset is designed so that date + offset = GMT. Timmy
   computes the offset from GMT, date - offset = GMT. *)
let timezone_local =
  let offset_calendar_time_s ~date:(year, month, day)
      ~time:(hours, minutes, seconds) =
    let () =
      let is_input_ok =
        Result.is_ok (Timmy.Date.of_tuple (year, month, day))
        && Result.is_ok (Timmy.Daytime.of_tuple (hours, minutes, seconds))
      in
      match is_input_ok with
      | true -> ()
      | false ->
        Fmt.failwith
          "Given date and time %04i-%02i-%02i at %02i:%02i:%02i are not valid"
          year month day hours minutes seconds
    in
    let js_date =
      new%js Js.date_sec year (month - 1) day hours minutes seconds
    in
    js_date##getTimezoneOffset * 60 * -1
  and offset_timestamp_s ~unix_timestamp =
    let () =
      if unix_timestamp < 0 then Fmt.failwith "Given timestamp is negative"
    in
    let js_date =
      new%js Js.date_fromTimeValue (float_of_int unix_timestamp *. 1000.0)
    in
    js_date##getTimezoneOffset * 60 * -1
  in
  of_implementation ~offset_calendar_time_s ~offset_timestamp_s

let today () = Timmy.Date.of_time ~timezone:timezone_local @@ now ()
