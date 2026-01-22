open! Base

let common_tz_ok () =
  if List.is_empty Timmy_timezones.available_zones then
    Alcotest.failf ~here:[%here] "The timezone list is empty"
  else
    List.iter Timmy_timezones.available_zones ~f:(fun name ->
        ignore @@ Timmy_timezones.of_string name)

let ( let+ ) = Result.( >>| )

let back_and_forth_daytime () =
  let timezone =
    Timmy_timezones.of_string "America/Los_Angeles" |> Option.value_exn
  in
  let date =
    Timmy.Date.make ~year:2025 ~month:January ~day:22 |> Result.ok_or_failwith
  and daytime = Timmy.Daytime.noon in
  Alcotest.(
    check @@ result (pair (module Timmy.Date) (module Timmy.Daytime)) string)
    "The first occurence is at the right daytime"
    (Result.Ok (date, daytime))
    (let+ time = Timmy.Daytime.to_time ~timezone date daytime in
     (Timmy.Date.of_time ~timezone time, Timmy.Daytime.of_time ~timezone time))

let nonexistent_datetime () =
  let timezone =
    Timmy_timezones.of_string "America/Sao_Paulo" |> Option.value_exn
  in
  let date =
    Timmy.Date.make ~year:2017 ~month:October ~day:15 |> Result.ok_or_failwith
  and daytime = Timmy.Daytime.midnight in
  Alcotest.(
    check @@ result (pair (module Timmy.Date) (module Timmy.Daytime)) pass)
    "Non existing datetimes are rejected" (Result.Error "")
    (let+ time = Timmy.Daytime.to_time ~timezone date daytime in
     (Timmy.Date.of_time ~timezone time, Timmy.Daytime.of_time ~timezone time))

let nonstandard repr () =
  Alcotest.(
    check bool (Fmt.str "non-standard timezone %S is recognized" repr) true
    @@ Option.is_some
    @@ Timmy_timezones.of_string repr)

let () =
  Alcotest.run "timmy-timezones"
    [
      ( "local",
        [
          Alcotest.test_case "common_tz_ok" `Quick common_tz_ok;
          Alcotest.test_case "back_and_forth_daytime" `Quick
            back_and_forth_daytime;
          Alcotest.test_case "nonexistent datetime" `Quick nonexistent_datetime;
        ] );
      ( "common",
        [
          Alcotest.test_case "common_timezone_test" `Quick
            (Clock_tests.daylight_savings
               ~timezone:
                 (Timmy_timezones.of_string "Europe/Amsterdam"
                 |> Option.value_exn));
        ] );
      ( "nonstandard",
        [
          Alcotest.test_case "Indiana/Indianapolis" `Quick
          @@ nonstandard "Indiana/Indianapolis";
        ] );
    ]
