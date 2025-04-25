open Base
open Testable

let ptime =
  Option.value_exn (Ptime.of_date_time ((1985, 12, 29), ((17, 35, 42), 0)))

let test_ptime = Alcotest.testable Ptime.pp Ptime.equal
let daytime = Alcotest.testable Timmy.Daytime.pp Timmy.Daytime.( = )
let gmt_plus_2 = Timmy.Timezone.of_gmt_offset_seconds @@ (60 * 60 * 2)
let gmt_plus_7 = Timmy.Timezone.of_gmt_offset_seconds @@ (60 * 60 * 7)

module Time = struct
  let birthday = Timmy.Time.of_ptime ptime

  let ptime () =
    Alcotest.check ~here:[%here] test_ptime "to_ptime" ptime
      (Timmy.Time.to_ptime birthday)

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

module Date = struct
  let make year month day =
    Timmy.Date.of_tuple_exn ~here:[%here] (year, month, day)

  let birthday = make 1985 12 29

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

  let pp () =
    let check name pp date expected =
      Alcotest.(check string) name expected (Fmt.str "%a" pp date)
    and reference = make 2022 8 1 in
    let check_relative name diff expected =
      check name
        Timmy.Date.(pp_relative ~reference)
        (Timmy.Date.add_days reference diff)
        expected
    in
    let () =
      check "human readable pretty printing" Timmy.Date.pp_human birthday
        "December 29th 1985"
    and () =
      check "far away relative pretty printing"
        Timmy.Date.(pp_relative ~reference)
        birthday "December 29th 1985"
    and () =
      check_relative "more than one week ago relative pretty printing" (-8)
        "July 24th 2022"
    and () =
      check_relative "one week ago relative pretty printing" (-7) "last Monday"
    and () =
      check_relative "yesterday relative pretty printing" (-1) "yesterday"
    and () = check_relative "yesterday relative pretty printing" 0 "today"
    and () = check_relative "tomorrow relative pretty printing" 1 "tomorrow"
    and () =
      check_relative "less than a week later relative pretty printing" 6
        "Sunday"
    and () =
      check_relative "one week later relative pretty printing" 7
        "August 8th 2022"
    in
    ()
end

module Span = struct
  let pp () =
    let check ~here name exp span =
      Alcotest.(
        check ~here string name exp (Fmt.str "%a" Timmy.Span.pp @@ span))
    in
    let check_seconds ~here ?(opposite = true) name exp seconds =
      check ~here name exp (Timmy.Span.seconds seconds);
      if opposite then
        check ~here name ("-" ^ exp) (Timmy.Span.seconds (-seconds))
    in
    let () =
      check_seconds ~here:[%here] "Seconds are printed correctly" "45s" 45
    and () =
      check_seconds ~here:[%here] "Minutes are printed correctly" "12m" (60 * 12)
    and () =
      check_seconds ~here:[%here] "Hours are printed correctly" "3h"
        (60 * 60 * 3)
    and () =
      check_seconds ~here:[%here] "One day is printed correctly" "1 day"
        (60 * 60 * 24)
    and () =
      check_seconds ~here:[%here] "Days are printed correctly" "7 days"
        (60 * 60 * 24 * 7)
    and () =
      check ~here:[%here] "Milliseconds are printed correctly" "0.003s"
      @@ Timmy.Span.of_ptime @@ Option.value_exn
      @@ Ptime.Span.of_float_s 0.003
    and () =
      check_seconds ~here:[%here] "A composite duration is printed correctly"
        "100 days 3h 58m 41s" 8654321
    and () =
      check_seconds ~here:[%here] ~opposite:false
        "Null span is printed correctly" "0s" 0
    and () =
      let span = Ptime.Span.of_float_s 0.123 in
      check ~here:[%here] "Milliseconds are printed correctly" "0.123s"
      @@ Timmy.Span.of_ptime @@ Option.value_exn span
    and () =
      let span = Ptime.Span.of_float_s 1.234 in
      check ~here:[%here] "Milliseconds are printed correctly" "1.234s"
      @@ Timmy.Span.of_ptime @@ Option.value_exn span
    and () =
      check ~here:[%here] "Multiplied correctly" "0.100s"
      @@ Timmy.Span.(seconds 1 *. 0.1)
    and () =
      Alcotest.check ~here:[%here] (Alcotest.float 0.01) "Divided correctly" 10.
      @@ Timmy.Span.(seconds 1 /. (seconds 1 *. 0.1))
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

  let comparison () =
    Alcotest.(check bool "comparisons" true Timmy.Weekday.(Monday = Monday));
    Alcotest.(
      check bool "comparisons" false Timmy.Weekday.(Wednesday = Tuesday));
    Alcotest.(check bool "comparisons" false Timmy.Weekday.(Monday <> Monday));
    Alcotest.(
      check bool "comparisons" true Timmy.Weekday.(Wednesday <> Tuesday))
end

module Daytime = struct
  let birthday = Timmy.Time.of_ptime ptime

  let check name (hours, minutes, seconds) eff =
    Alcotest.(check daytime)
      name
      (Option.value_exn ~here:[%here]
         (Result.ok @@ Timmy.Daytime.make ~hours ~minutes ~seconds))
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

  let pp () =
    let check time hours minutes minutes_long seconds seconds_long hours_12
        minutes_12 minutes_long_12 seconds_12 seconds_long_12 =
      let check name pp exp =
        Alcotest.(check string name exp) (Fmt.str "%a" pp time)
      in
      check "hours" (Timmy.Daytime.pp_opt ~precision:`Hours ()) hours;
      check "minutes" (Timmy.Daytime.pp_opt ~precision:`Minutes ()) minutes;
      check "minutes"
        (Timmy.Daytime.pp_opt ~precision:`Minutes ~size:`Long ())
        minutes_long;
      check "seconds" (Timmy.Daytime.pp_opt ~precision:`Seconds ()) seconds;
      check "default" (Timmy.Daytime.pp_opt ()) seconds;
      check "seconds"
        (Timmy.Daytime.pp_opt ~precision:`Seconds ~size:`Long ())
        seconds_long;
      check "hours"
        (Timmy.Daytime.pp_opt ~format:`_12 ~precision:`Hours ())
        hours_12;
      check "minutes"
        (Timmy.Daytime.pp_opt ~format:`_12 ~precision:`Minutes ())
        minutes_12;
      check "minutes"
        (Timmy.Daytime.pp_opt ~format:`_12 ~precision:`Minutes ~size:`Long ())
        minutes_long_12;
      check "seconds"
        (Timmy.Daytime.pp_opt ~format:`_12 ~precision:`Seconds ())
        seconds_12;
      check "default" (Timmy.Daytime.pp_opt ~format:`_12 ()) seconds_12;
      check "seconds"
        (Timmy.Daytime.pp_opt ~format:`_12 ~precision:`Seconds ~size:`Long ())
        seconds_long_12
    in
    check
      (Timmy.Daytime.make ~hours:2 ~minutes:0 ~seconds:0
      |> Result.ok_or_failwith)
      "02" "02" "02:00" "02" "02:00:00" "2AM" "2AM" "2:00AM" "2AM" "2:00:00AM";
    check Timmy.Daytime.midnight "00" "00" "00:00" "00" "00:00:00" "12AM" "12AM"
      "12:00AM" "12AM" "12:00:00AM";
    check Timmy.Daytime.noon "12" "12" "12:00" "12" "12:00:00" "12PM" "12PM"
      "12:00PM" "12PM" "12:00:00PM";
    check Timmy.Daytime.latest "23" "23:59" "23:59" "23:59:59" "23:59:59" "11PM"
      "11:59PM" "11:59PM" "11:59:59PM" "11:59:59PM"
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

  let comparison () =
    Alcotest.(check bool "comparisons" false Timmy.Month.(January < January));
    Alcotest.(check bool "comparisons" true Timmy.Month.(January < February));
    Alcotest.(check bool "comparisons" false Timmy.Month.(February < January));
    Alcotest.(check bool "comparisons" true Timmy.Month.(March = March));
    Alcotest.(check bool "comparisons" false Timmy.Month.(March <> March));
    Alcotest.(check bool "comparisons" true Timmy.Month.(April <> May));
    Alcotest.(check bool "comparisons" false Timmy.Month.(April = May))
end

module Week = struct
  let week = Alcotest.testable Timmy.Week.pp Timmy.Week.equal

  let construction () =
    let check exp year n =
      let eff =
        Result.map ~f:(fun Timmy.Week.{ n; year } -> (year, n))
        @@ Timmy.Week.make ~year n
      in
      Alcotest.(
        check
          (result (pair int int) string)
          (Fmt.str "%04i-%02i" year n)
          exp eff)
    in
    check (Result.Ok (2021, 1)) 2021 1;
    check (Result.Ok (2021, 52)) 2021 52;
    check (Result.Ok (2020, 53)) 2020 53;
    check (Result.Error "year 2021 has no week 53") 2021 53;
    check (Result.Error "week 0 is less than 1") 2021 0;
    check (Result.Error "week 54 is greater than 53") 2021 54

  let to_date () =
    let check exp year n =
      let eff = Timmy.Week.make ~year n |> Result.ok_or_failwith
      and monday = Timmy.Date.of_tuple_exn ~here:[%here] exp in
      Alcotest.(
        check date
          (Fmt.str "to_date %a" Timmy.Week.pp eff)
          monday (Timmy.Week.to_date eff));
      Base.Sequence.(iter (range 0 7)) ~f:(fun i ->
          Alcotest.(
            check week
              (Fmt.str "of_date %a" Timmy.Date.pp
                 (Timmy.Date.add_days monday i))
              (Timmy.Week.of_date monday)
              eff))
    in
    check (2021, 12, 27) 2021 52;
    check (2022, 1, 3) 2022 1;
    check (2022, 12, 26) 2022 52

  let sum () =
    let check (year_start, n_start) i (year_exp, n_exp) =
      let start =
        Timmy.Week.make ~year:year_start n_start |> Result.ok_or_failwith
      and exp = Timmy.Week.make ~year:year_exp n_exp |> Result.ok_or_failwith in
      let eff = Timmy.Week.(start + i)
      and name = Fmt.str "%a + %i" Timmy.Week.pp start i in
      Alcotest.check ~here:[%here] week name exp eff
    in
    check (2021, 52) 0 (2021, 52);
    check (2021, 52) 1 (2022, 1);
    check (2021, 52) (-1) (2021, 51);
    check (2022, 1) (-1) (2021, 52);
    check (2020, 52) 0 (2020, 52);
    check (2020, 52) 1 (2020, 53);
    check (2020, 52) (-1) (2020, 51);
    check (2021, 1) (-1) (2020, 53)
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
            test_case "pretty printing" `Quick Date.pp;
          ] );
        ( "daytime",
          [
            test_case "pretty printing" `Quick Daytime.pp;
            test_case "time conversion" `Quick Daytime.of_time;
          ] );
        ( "month",
          [
            test_case "int conversions" `Quick Month.int;
            test_case "pretty printing" `Quick Month.pp;
            test_case "comparison" `Quick Month.comparison;
          ] );
        ("span", [ test_case "pretty printing" `Quick Span.pp ]);
        ( "week",
          [
            test_case "construction" `Quick Week.construction;
            test_case "to_date" `Quick Week.to_date;
            test_case "sum" `Quick Week.sum;
          ] );
        ( "weekday",
          [
            test_case "int conversions" `Quick Weekday.int;
            test_case "pretty printing" `Quick Weekday.pp;
            test_case "comparison" `Quick Weekday.comparison;
          ] );
        ("schemas", Schemas.tests);
      ])
