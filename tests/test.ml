open Acid

let ptime =
  Option.value_exn (Ptime.of_date_time ((1985, 12, 29), ((17, 35, 42), 0)))

let test_ptime = Alcotest.testable Ptime.pp Ptime.equal

let test_time = Alcotest.testable Timmy.Time.pp Timmy.Time.( = )

module Time = struct
  let time = Timmy.Time.of_ptime ptime

  let ptime () =
    Alcotest.check test_ptime "to_ptime" ptime (Timmy.Time.to_ptime time)

  let pp () =
    let () =
      Alcotest.(
        check string "to_string" "1985-12-29 17:35:42 +00:00"
          (Timmy.Time.to_string time))
    and () =
      Alcotest.(
        check string "to_string" "1985-12-29 17:35:42 +00:00"
          (Fmt.str "%a" Timmy.Time.pp time))
    in
    ()
end

let () =
  Alcotest.(
    run "Timmy"
      [
        ( "time",
          [
            test_case "ptime" `Quick Time.ptime;
            test_case "pretty-print" `Quick Time.pp;
          ] );
      ])
