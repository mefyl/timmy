open! Base

let common_tz_ok () =
  if List.is_empty Timmy_timezones.available_zones then
    Alcotest.failf ~here:[%here] "The timezone list is empty"
  else
    List.iter Timmy_timezones.available_zones ~f:(fun name ->
        ignore @@ Timmy_timezones.of_string name)

let () =
  Alcotest.run "timmy-timezones"
    [
      ("local", [ Alcotest.test_case "common_tz_ok" `Quick common_tz_ok ]);
      ( "common",
        [
          Alcotest.test_case "common_timezone_test" `Quick
            (Clock_tests.daylight_savings
               ~timezone:
                 (Timmy_timezones.of_string "Europe/Amsterdam"
                 |> Option.value_exn));
        ] );
    ]
