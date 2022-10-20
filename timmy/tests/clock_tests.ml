(* These tests only make sense if run on a machine that is in CEST/CET timezone.
   Use `env TZ='Europe/Paris' node test.bc.js` *)

let timezone = Clock.timezone_local

let daylight_savings () =
  let test date ((_, h, m) as time) =
    let shift =
      Timmy.Timezone.gmt_offset_seconds_at_datetime ~date ~time timezone
      / 60 / 60
    in
    let date_t = Timmy.Date.of_tuple_exn ~here:[%here] date
    and time_t = Timmy.Daytime.of_tuple_exn ~here:[%here] time in
    let timestamp = Timmy.Daytime.to_time ~timezone date_t time_t in
    let _, h_shifted, m_shifted =
      Timmy.Daytime.of_time ~timezone timestamp |> Timmy.Daytime.to_tuple
    in
    let shift_ts =
      Timmy.Timezone.gmt_offset_seconds_at_time timezone
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
    and () =
      Alcotest.(
        check int
          (Fmt.str "%s: minutes should be unchanged by timeshift" pretty_date)
          m m_shifted)
    in
    ()
  and test_relaxed date ((_, h, m) as time) =
    let date_t = Timmy.Date.of_tuple_exn ~here:[%here] date
    and time_t = Timmy.Daytime.of_tuple_exn ~here:[%here] time in
    let timestamp = Timmy.Daytime.to_time ~timezone date_t time_t in
    let _, h_shifted, m_shifted =
      Timmy.Daytime.of_time ~timezone timestamp |> Timmy.Daytime.to_tuple
    in
    let pretty_date =
      Fmt.str "%a at %a is %s" Timmy.Date.pp date_t Timmy.Daytime.pp time_t
        (Timmy.Time.to_rfc3339 timestamp ~timezone)
    in
    let () =
      Alcotest.(
        check bool
          (Fmt.str
             "%s: hours should only be inconsistent by one hour during \
              timeshift"
             pretty_date)
          (abs (h - h_shifted) <= 1)
          true)
    and () =
      Alcotest.(
        check int
          (Fmt.str "%s: minutes should be unchanged by timeshift" pretty_date)
          m m_shifted)
    in
    ()
  in
  (* right before the timeshift. *)
  test (2022, 3, 26) (23, 59, 59);
  test (2022, 3, 27) (1, 59, 59);

  (* right after the timeshift. *)
  test (2022, 3, 27) (3, 0, 0);

  (* during the timeshift. *)
  test_relaxed (2022, 3, 27) (2, 0, 0);
  test_relaxed (2022, 3, 27) (2, 59, 59);
  ()
