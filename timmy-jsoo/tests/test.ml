module Timmy = Timmy_jsoo
module Js = Js_of_ocaml.Js

(* These tests only make sense if run on a machine that is in CEST/CET timezone.
   Use `env TZ='Europe/Paris' node test.bc.js` *)

(* let _ = Js.Unsafe.eval_string "process.env.TZ = 'Europe/Paris'" (* You can
   use that before you ask for any dates, this will set the timezone *) *)

let timezone = Timmy_jsoo.Timezone.native

let daylight_savings () =
  let test date ((_, h, _) as time) =
    let shift =
      Timmy.Timezone.gmt_offset_seconds_with_datetime ~date ~time timezone
      / 60 / 60
    in
    let date_t = Timmy.Date.of_tuple_exn ~here:[%here] date
    and time_t = Timmy_jsoo.Daytime.of_tuple_exn ~here:[%here] time in
    let timestamp = Timmy.Daytime.to_time ~timezone date_t time_t in
    let _, h_shifted, _ =
      Timmy.Daytime.of_time ~timezone timestamp |> Timmy.Daytime.to_tuple
    in
    let shift_ts =
      Timmy.Timezone.gmt_offset_seconds_with_ptime timezone
        (Timmy.Time.to_ptime timestamp)
      / 60 / 60
    in
    let pretty_date =
      Fmt.str "%a at %a is %s" Timmy.Date.pp date_t Timmy.Daytime.pp time_t
        (Timmy.Time.to_rfc3339 timestamp ~timezone)
    in
    let () =
      Alcotest.(
        check bool
          (Fmt.str "%s: Timezone was not set properly, needs to be in CET."
             pretty_date)
          (shift_ts != 0) true)
    in
    let () =
      Alcotest.(
        check int
          (Fmt.str
             "%s: Computed offset for date and timestamps have to be equal"
             pretty_date)
          shift_ts shift)
    and () =
      Alcotest.(
        check int
          (Fmt.str "%s: hour should be unchanged by timeshift" pretty_date)
          h h_shifted)
    in
    ()
  in
  test (2022, 3, 26) (23, 59, 59);
  test (2022, 3, 27) (1, 59, 59);
  (* right before the timeshift. *)
  test (2022, 3, 27) (3, 0, 0);
  (* right after the timeshift. *)
  ()

let () =
  Alcotest.(
    run "Timmy-jsoo"
      [ ("timezone", [ test_case "daylight saving" `Quick daylight_savings ]) ])
