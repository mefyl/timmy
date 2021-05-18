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

  let arithmetics () =
    let check name exp eff =
      Alcotest.(check date) name (Timmy.Date.of_tuple_exn ~here:[%here] exp) eff
    in
    let () =
      check "adding days works" (1985, 12, 30) @@ Timmy.Date.add_days birthday 1
    and () =
      check "substracting days works" (1985, 12, 28)
      @@ Timmy.Date.add_days birthday (-1)
    and () =
      check "adding days works accross years boundaries" (1986, 1, 1)
      @@ Timmy.Date.add_days birthday 3
    and () =
      check "substracting days works accross month boundaries" (1985, 11, 29)
      @@ Timmy.Date.add_days birthday (-30)
    in
    ()
end

module Weekday = struct
  let int () =
    let () =
      Alcotest.(
        check int "Monday is converted correctly" 0 (Timmy.Weekday.to_int `Mon))
    and () =
      Alcotest.(
        check int "Tuesday is converted correctly" 1 (Timmy.Weekday.to_int `Tue))
    and () =
      Alcotest.(
        check int "Wednesday is converted correctly" 2
          (Timmy.Weekday.to_int `Wed))
    and () =
      Alcotest.(
        check int "Thursday is converted correctly" 3
          (Timmy.Weekday.to_int `Thu))
    and () =
      Alcotest.(
        check int "Friday is converted correctly" 4 (Timmy.Weekday.to_int `Fri))
    and () =
      Alcotest.(
        check int "Saturday is converted correctly" 5
          (Timmy.Weekday.to_int `Sat))
    and () =
      Alcotest.(
        check int "Sunday is converted correctly" 6 (Timmy.Weekday.to_int `Sun))
    and () =
      Alcotest.(
        check int "conversions with a base in the future works" 3
          (Timmy.Weekday.to_int ~base:`Sat `Tue))
    and () =
      Alcotest.(
        check int "conversions with a base the same day works" 0
          (Timmy.Weekday.to_int ~base:`Sun `Sun))
    and () =
      Alcotest.(
        check int "conversions with a base in the past works" 1
          (Timmy.Weekday.to_int ~base:`Sat `Sun))
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
        ( "date",
          [
            test_case "string conversions" `Quick Date.string;
            test_case "arithmetics" `Quick Date.arithmetics;
          ] );
        ("weekday", [ test_case "int conversions" `Quick Weekday.int ]);
      ])
