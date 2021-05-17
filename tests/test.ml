open Acid

let ptime =
  Option.value_exn (Ptime.of_date_time ((1985, 12, 29), ((17, 35, 42), 0)))

let test_ptime = Alcotest.testable Ptime.pp Ptime.equal

let time = Alcotest.testable Timmy.Time.pp Timmy.Time.( = )

module Time = struct
  let birthday = Timmy.Time.of_ptime ptime

  let ptime () =
    Alcotest.check test_ptime "to_ptime" ptime (Timmy.Time.to_ptime birthday)

  let string () =
    let check = Alcotest.(check (result time string)) in
    let () =
      check "conversion from valid string works" (Result.Ok birthday)
        (Timmy.Time.of_string "1985-12-29T17:35:42.000+00:00")
    and () =
      check "parse errors are detected"
        (Result.Error "invalid date: expected a character in: '-'")
        (Timmy.Time.of_string "1985-12+29T17:35:42.000+00:00")
    in
    ()

  let pp () =
    let () =
      Alcotest.(
        check string "to_string" "1985-12-29 17:35:42 +00:00"
          (Timmy.Time.to_string birthday))
    and () =
      Alcotest.(
        check string "to_string" "1985-12-29 17:35:42 +00:00"
          (Fmt.str "%a" Timmy.Time.pp birthday))
    in
    ()
end

let date = Alcotest.testable Timmy.Date.pp Timmy.Date.( = )

module Date = struct
  let birthday = Timmy.Date.of_tuple_exn ~here:[%here] (1985, 12, 29)

  let string () =
    let check = Alcotest.(check (result date string)) in
    let () =
      check "conversion from valid string works" (Result.Ok birthday)
        (Timmy.Date.of_string "1985-12-29")
    and () =
      check "parse errors are detected" (Result.Error "invalid date: 1985-12")
        (Timmy.Date.of_string "1985-12")
    and () =
      check "non-integer is rejected" (Result.Error "invalid year: 198S")
        (Timmy.Date.of_string "198S-12-29")
    and () =
      check "non-integer is rejected" (Result.Error "invalid month: 1+2")
        (Timmy.Date.of_string "1985-1+2-29")
    and () =
      check "non-integer is rejected" (Result.Error "invalid day: 2a")
        (Timmy.Date.of_string "1985-12-2a")
    and () =
      check "invalid calendar date is rejected"
        (Result.Error "invalid date: 1985-11-31")
        (Timmy.Date.of_string "1985-11-31")
    in
    ()
end

let () =
  Alcotest.(
    run "Timmy"
      [
        ( "time",
          [
            test_case "string conversions" `Quick Time.string;
            test_case "ptime" `Quick Time.ptime;
            test_case "pretty-print" `Quick Time.pp;
          ] );
        ("date", [ test_case "string conversions" `Quick Date.string ]);
      ])
