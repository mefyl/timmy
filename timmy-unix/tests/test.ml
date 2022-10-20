let () =
  Alcotest.(
    run "Timmy-unix"
      [
        ( "timezone",
          [ test_case "daylight saving" `Quick Clock_tests.daylight_savings ] );
      ])
