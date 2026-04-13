let () =
  Alcotest.(
    run "Timmy-jsoo"
      [
        ( "timezone",
          [
            test_case "daylight saving" `Quick Clock_tests.daylight_savings;
            test_case "ancient date offset" `Quick
              Clock_tests.ancient_date_offset;
          ] );
      ])
