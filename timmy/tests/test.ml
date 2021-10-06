open Acid

let ptime =
  Option.value_exn (Ptime.of_date_time ((1985, 12, 29), ((17, 35, 42), 0)))

let test_ptime = Alcotest.testable Ptime.pp Ptime.equal

let time = Alcotest.testable Timmy.Time.pp Timmy.Time.( = )

let daytime = Alcotest.testable Timmy.Daytime.pp Timmy.Daytime.( = )

let gmt_plus_2 = Timmy.Timezone.of_gmt_offset_seconds @@ (60 * 60 * 2)

let gmt_plus_7 = Timmy.Timezone.of_gmt_offset_seconds @@ (60 * 60 * 7)

module Time = struct
  let birthday = Timmy.Time.of_ptime ptime

  let ptime () =
    Alcotest.check test_ptime "to_ptime" ptime (Timmy.Time.to_ptime birthday)

  let rfc3339 () =
    let () =
      let check = Alcotest.(check (result time string)) in
      let () =
        check "conversion from RFC3339 works" (Result.Ok birthday)
          (Timmy.Time.of_rfc3339 "1985-12-29T17:35:42.000+00:00")
      and () =
        check "conversion from RFC3339 with timezone works" (Result.Ok birthday)
          (Timmy.Time.of_rfc3339 "1985-12-29T19:35:42.000+02:00")
      and () =
        check "parse errors are detected"
          (Result.Error "invalid date: expected a character in: '-'")
          (Timmy.Time.of_rfc3339 "1985-12+29T17:35:42.000+00:00")
      in
      ()
    and () =
      let check = Alcotest.(check string) in
      let () =
        check "conversion to RFC3339 works" "1985-12-29T17:35:42-00:00"
          (Timmy.Time.to_rfc3339 birthday)
      and () =
        check "conversion to RFC3339 works" "1985-12-29T19:35:42+02:00"
          (Timmy.Time.to_rfc3339 ~timezone:gmt_plus_2 birthday)
      in
      ()
    in
    ()

  let pp () =
    let () =
      Alcotest.(
        check string "to_string" "1985-12-29T17:35:42-00:00"
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

  let check name exp eff =
    Alcotest.(check date) name (Timmy.Date.of_tuple_exn ~here:[%here] exp) eff

  let overflow () =
    let () =
      check "valid date is untouched" (1985, 12, 29)
      @@ Timmy.Date.make_overflow ~year:1985 ~month:12 ~day:29 ()
    and () =
      check "months overflow" (1986, 01, 29)
      @@ Timmy.Date.make_overflow ~year:1985 ~month:13 ~day:29 ()
    and () =
      check "months underflow" (1984, 12, 29)
      @@ Timmy.Date.make_overflow ~year:1985 ~month:0 ~day:29 ()
    and () =
      check "days overflow" (1985, 3, 1)
      @@ Timmy.Date.make_overflow ~year:1985 ~month:2 ~day:29 ()
    and () =
      check "days underflow" (1985, 2, 28)
      @@ Timmy.Date.make_overflow ~year:1985 ~month:3 ~day:0 ()
    and () =
      check "days trucate down" (1985, 2, 28)
      @@ Timmy.Date.make_overflow ~day_truncate:true ~year:1985 ~month:2 ~day:29
           ()
    and () =
      check "days truncate up" (1985, 3, 1)
      @@ Timmy.Date.make_overflow ~day_truncate:true ~year:1985 ~month:3 ~day:0
           ()
    and () =
      check "days overflow across months and years" (1986, 1, 1)
      @@ Timmy.Date.make_overflow ~year:1985 ~month:11 ~day:62 ()
    and () =
      check "days underflow across months and years" (1984, 12, 31)
      @@ Timmy.Date.make_overflow ~year:1985 ~month:3 ~day:(-59) ()
    in
    ()

  let arithmetics () =
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

  let of_time () =
    let birthday = Timmy.Time.of_ptime ptime in
    let () =
      check "from time" (1985, 12, 29)
      @@ Timmy.Date.of_time ~timezone:Timmy.Timezone.utc birthday
    and () =
      check "from time with timezone" (1985, 12, 29)
      @@ Timmy.Date.of_time ~timezone:gmt_plus_2 birthday
    and () =
      check "from time with timezone across day" (1985, 12, 30)
      @@ Timmy.Date.of_time ~timezone:gmt_plus_7 birthday
    in
    ()
end

module Weekday = struct
  let int () =
    let () =
      Alcotest.(
        check int "Monday is converted correctly" 0
          (Timmy.Weekday.to_int Monday))
    and () =
      Alcotest.(
        check int "Tuesday is converted correctly" 1
          (Timmy.Weekday.to_int Tuesday))
    and () =
      Alcotest.(
        check int "Wednesday is converted correctly" 2
          (Timmy.Weekday.to_int Wednesday))
    and () =
      Alcotest.(
        check int "Thursday is converted correctly" 3
          (Timmy.Weekday.to_int Thursday))
    and () =
      Alcotest.(
        check int "Friday is converted correctly" 4
          (Timmy.Weekday.to_int Friday))
    and () =
      Alcotest.(
        check int "Saturday is converted correctly" 5
          (Timmy.Weekday.to_int Saturday))
    and () =
      Alcotest.(
        check int "Sunday is converted correctly" 6
          (Timmy.Weekday.to_int Sunday))
    and () =
      Alcotest.(
        check int "conversions with a base in the future works" 3
          (Timmy.Weekday.to_int ~base:Saturday Tuesday))
    and () =
      Alcotest.(
        check int "conversions with a base the same day works" 0
          (Timmy.Weekday.to_int ~base:Sunday Sunday))
    and () =
      Alcotest.(
        check int "conversions with a base in the past works" 1
          (Timmy.Weekday.to_int ~base:Saturday Sunday))
    in
    ()

  let pp () =
    let () =
      Alcotest.(
        check string "Monday is converted correctly" "Monday"
          (Fmt.str "%a" Timmy.Weekday.pp Monday))
    and () =
      Alcotest.(
        check string "Tuesday is converted correctly" "Tuesday"
          (Fmt.str "%a" Timmy.Weekday.pp Tuesday))
    and () =
      Alcotest.(
        check string "Wednesday is converted correctly" "Wednesday"
          (Fmt.str "%a" Timmy.Weekday.pp Wednesday))
    and () =
      Alcotest.(
        check string "Thursday is converted correctly" "Thursday"
          (Fmt.str "%a" Timmy.Weekday.pp Thursday))
    and () =
      Alcotest.(
        check string "Friday is converted correctly" "Friday"
          (Fmt.str "%a" Timmy.Weekday.pp Friday))
    and () =
      Alcotest.(
        check string "Saturday is converted correctly" "Saturday"
          (Fmt.str "%a" Timmy.Weekday.pp Saturday))
    and () =
      Alcotest.(
        check string "Sunday is converted correctly" "Sunday"
          (Fmt.str "%a" Timmy.Weekday.pp Sunday))
    in
    ()
end

module Daytime = struct
  let birthday = Timmy.Time.of_ptime ptime

  let check name (hours, minutes, seconds) eff =
    Alcotest.(check daytime)
      name
      (Option.value_exn ~here:[%here]
         (Result.to_option @@ Timmy.Daytime.make ~hours ~minutes ~seconds))
      eff

  let of_time () =
    let () =
      check "conversion from time" (17, 35, 42)
      @@ Timmy.Daytime.of_time ~timezone:Timmy.Timezone.utc birthday
    and () =
      check "conversion from time with timezone" (19, 35, 42)
      @@ Timmy.Daytime.of_time ~timezone:gmt_plus_2 birthday
    and () =
      check "conversion from time with timezone across day" (00, 35, 42)
      @@ Timmy.Daytime.of_time ~timezone:gmt_plus_7 birthday
    in
    ()
end

module Month = struct
  let int () =
    let () =
      Alcotest.(
        check int "January is converted correctly" 1
          (Timmy.Month.to_int January))
    and () =
      Alcotest.(
        check int "February is converted correctly" 2
          (Timmy.Month.to_int February))
    and () =
      Alcotest.(
        check int "March is converted correctly" 3 (Timmy.Month.to_int March))
    and () =
      Alcotest.(
        check int "April is converted correctly" 4 (Timmy.Month.to_int April))
    and () =
      Alcotest.(
        check int "May is converted correctly" 5 (Timmy.Month.to_int May))
    and () =
      Alcotest.(
        check int "June is converted correctly" 6 (Timmy.Month.to_int June))
    and () =
      Alcotest.(
        check int "July is converted correctly" 7 (Timmy.Month.to_int July))
    and () =
      Alcotest.(
        check int "August is converted correctly" 8 (Timmy.Month.to_int August))
    and () =
      Alcotest.(
        check int "September is converted correctly" 9
          (Timmy.Month.to_int September))
    and () =
      Alcotest.(
        check int "October is converted correctly" 10
          (Timmy.Month.to_int October))
    and () =
      Alcotest.(
        check int "November is converted correctly" 11
          (Timmy.Month.to_int November))
    and () =
      Alcotest.(
        check int "December is converted correctly" 12
          (Timmy.Month.to_int December))
    in
    ()

  let pp () =
    let () =
      Alcotest.(
        check string "January is converted correctly" "January"
          (Fmt.str "%a" Timmy.Month.pp January))
    and () =
      Alcotest.(
        check string "February is converted correctly" "February"
          (Fmt.str "%a" Timmy.Month.pp February))
    and () =
      Alcotest.(
        check string "March is converted correctly" "March"
          (Fmt.str "%a" Timmy.Month.pp March))
    and () =
      Alcotest.(
        check string "April is converted correctly" "April"
          (Fmt.str "%a" Timmy.Month.pp April))
    and () =
      Alcotest.(
        check string "May is converted correctly" "May"
          (Fmt.str "%a" Timmy.Month.pp May))
    and () =
      Alcotest.(
        check string "June is converted correctly" "June"
          (Fmt.str "%a" Timmy.Month.pp June))
    and () =
      Alcotest.(
        check string "July is converted correctly" "July"
          (Fmt.str "%a" Timmy.Month.pp July))
    and () =
      Alcotest.(
        check string "August is converted correctly" "August"
          (Fmt.str "%a" Timmy.Month.pp August))
    and () =
      Alcotest.(
        check string "September is converted correctly" "September"
          (Fmt.str "%a" Timmy.Month.pp September))
    and () =
      Alcotest.(
        check string "October is converted correctly" "October"
          (Fmt.str "%a" Timmy.Month.pp October))
    and () =
      Alcotest.(
        check string "November is converted correctly" "November"
          (Fmt.str "%a" Timmy.Month.pp November))
    and () =
      Alcotest.(
        check string "December is converted correctly" "December"
          (Fmt.str "%a" Timmy.Month.pp December))
    in
    ()
end

let () =
  Alcotest.(
    run "Timmy"
      [
        ( "time",
          [
            test_case "RFC3339 conversions" `Quick Time.rfc3339;
            test_case "ptime" `Quick Time.ptime;
            test_case "pretty-print" `Quick Time.pp;
          ] );
        ( "date",
          [
            test_case "string conversions" `Quick Date.string;
            test_case "arithmetics" `Quick Date.arithmetics;
            test_case "time conversion" `Quick Date.of_time;
            test_case "overflow" `Quick Date.overflow;
          ] );
        ("daytime", [ test_case "time conversion" `Quick Daytime.of_time ]);
        ( "month",
          [
            test_case "int conversions" `Quick Month.int;
            test_case "pretty printing" `Quick Month.pp;
          ] );
        ( "weekday",
          [
            test_case "int conversions" `Quick Weekday.int;
            test_case "pretty printing" `Quick Weekday.pp;
          ] );
      ])
