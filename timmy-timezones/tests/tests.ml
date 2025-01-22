open! Base

let common_tz_ok () =
  if List.is_empty Timmy_timezones.available_zones then
    Alcotest.failf ~here:[%here] "The timezone list is empty"
  else
    List.iter Timmy_timezones.available_zones ~f:(fun name ->
        ignore @@ Timmy_timezones.of_string name)

let back_and_forth_daytime () =
  let timezone =
    Timmy_timezones.of_string "America/Los_Angeles" |> Option.value_exn
  in
  let date =
    Timmy.Date.make ~year:2025 ~month:January ~day:22 |> Result.ok_or_failwith
  and daytime = Timmy.Daytime.noon in
  Alcotest.check
    (Alcotest.pair (module Timmy.Date) (module Timmy.Daytime))
    "The first occurence is at the right daytime" (date, daytime)
    (let time = Timmy.Daytime.to_time ~timezone date daytime in
     (Timmy.Date.of_time ~timezone time, Timmy.Daytime.of_time ~timezone time))

let () =
  Alcotest.run "timmy-timezones"
    [
      ( "local",
        [
          Alcotest.test_case "common_tz_ok" `Quick common_tz_ok;
          Alcotest.test_case "back_and_forth_daytime" `Quick
            back_and_forth_daytime;
        ] );
      ( "common",
        [
          Alcotest.test_case "common_timezone_test" `Quick
            (Clock_tests.daylight_savings
               ~timezone:
                 (Timmy_timezones.of_string "Europe/Amsterdam"
                 |> Option.value_exn));
        ] );
    ]
