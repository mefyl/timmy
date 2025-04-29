let () =
  Alcotest.(
    run "Timmy-jsoo"
      [
        ( "timezone",
          [ test_case "daylight saving" `Quick Clock_tests.daylight_savings ] );
      ])
