(* These tests only make sense if run on a machine that is in CEST/CET timezone.
   Use `env TZ='Europe/Paris' node test.bc.js` *)

let timezone = Clock.timezone_local

module Alcotest = struct
  include Alcotest

  let date = testable Timmy.Date.pp Timmy.Date.equal
  let daytime = testable Timmy.Daytime.pp Timmy.Daytime.equal
end

let daylight_savings () =
  let test offset date time =
    let date_t = Timmy.Date.of_tuple_exn ~here:[%here] date
    and time_t = Timmy.Daytime.of_tuple_exn ~here:[%here] time in
    let timestamp = Timmy.Daytime.to_time ~timezone date_t time_t in
    let () =
      Alcotest.(check ~here:[%here] int)
        (Fmt.str "UTC offset at %a %a" Timmy.Date.pp date_t Timmy.Daytime.pp
           time_t)
        offset
      @@ Timmy.Timezone.gmt_offset_seconds_at_datetime ~date ~time timezone
         / 60 / 60
    and () =
      Alcotest.(check ~here:[%here] int)
        (Fmt.str "UTC offset at %a" Timmy.Time.pp timestamp)
        offset
      @@ Timmy.Timezone.gmt_offset_seconds_at_time timezone
           (Timmy.Time.to_ptime timestamp)
         / 60 / 60
    and () =
      Alcotest.(check ~here:[%here] date) "date roundtrip" date_t
      @@ Timmy.Date.of_time ~timezone timestamp
    and () =
      Alcotest.(check ~here:[%here] daytime) "daytime roundtrip" time_t
      @@ Timmy.Daytime.of_time ~timezone timestamp
    in
    ()
  and test_relaxed date ((hours, minutes, seconds) as time) =
    let date_t = Timmy.Date.of_tuple_exn ~here:[%here] date
    and time_t = Timmy.Daytime.of_tuple_exn ~here:[%here] time in
    let timestamp = Timmy.Daytime.to_time ~timezone date_t time_t in
    let hours_shifted, minutes_shifted, seconds_shifted =
      Timmy.Daytime.of_time ~timezone timestamp |> Timmy.Daytime.to_tuple
    in
    let () =
      Alcotest.(
        check ~here:[%here] bool "hours differ by at most 1 after roundtrip"
          (abs (hours - hours_shifted) <= 1)
          true)
    and () =
      Alcotest.(
        check ~here:[%here] int "minutes are unchanged by roundtrip" minutes
          minutes_shifted)
    and () =
      Alcotest.(
        check ~here:[%here] int "seconds are unchanged by roundtrip" seconds
          seconds_shifted)
    in
    ()
  in

  (* right before the timeshift. *)
  test 1 (2022, 3, 26) (23, 59, 59);
  test 1 (2022, 3, 27) (1, 59, 59);

  (* right after the timeshift. *)
  test 2 (2022, 3, 27) (3, 0, 0);

  (* during the timeshift. *)
  test_relaxed (2022, 3, 27) (2, 0, 0);
  test_relaxed (2022, 3, 27) (2, 59, 59);
  ()
