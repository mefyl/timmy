(* These tests only make sense if run on a machine that is in CEST/CET timezone.
   Use `env TZ='Europe/Paris' node test.bc.js` *)

module Timmy = Timmy.Versions.V1_1

module Alcotest = struct
  include Alcotest

  let date = testable Timmy.Date.pp Timmy.Date.equal
  let daytime = testable Timmy.Daytime.pp Timmy.Daytime.equal
end

let daylight_savings ?(timezone = Clock.timezone_local) () =
  let test offset date time =
    let date_t = Timmy.Date.of_tuple_exn ~here:[%here] date
    and time_t = Timmy.Daytime.of_tuple_exn ~here:[%here] time in
    let timestamp = Timmy.Daytime.to_time ~timezone date_t time_t in
    let () =
      Alcotest.(check ~here:[%here] int)
        (Fmt.str "UTC offset at %a %a" Timmy.Date.pp date_t Timmy.Daytime.pp
           time_t)
        offset
      @@ Timmy.Timezone.gmt_offset_seconds_at_datetime ~date ~time timezone
         / 60
         / 60
    and () =
      Alcotest.(check ~here:[%here] int)
        (Fmt.str "UTC offset at %a" Timmy.Time.pp timestamp)
        offset
      @@ Timmy.Timezone.gmt_offset_seconds_at_time timezone
           (Timmy.Time.to_ptime timestamp)
         / 60
         / 60
    and () =
      Alcotest.(check ~here:[%here] date) "date roundtrip" date_t
      @@ Timmy.Date.of_time ~timezone timestamp
    and () =
      Alcotest.(check ~here:[%here] daytime) "daytime roundtrip" time_t
      @@ Timmy.Daytime.of_time ~timezone timestamp
    in
    ()
  in

  (* right before the timeshift. *)
  test 1 (2022, 3, 26) (23, 59, 59);
  test 1 (2022, 3, 27) (1, 59, 59);

  (* right after the timeshift. *)
  test 2 (2022, 3, 27) (3, 0, 0);
  ()

let timezone_name () =
  let name = Clock.timezone_local |> Timmy.Timezone.name in
  (* All these timezones are equivalent, and it's OK for the library to
     normalize it *)
  let expecteds = [ "Europe/Brussels"; "Europe/Paris"; "Europe/Amsterdam" ] in
  if List.exists (String.equal name) expecteds then ()
  else
    Alcotest.failf ~here:[%here] "Timezone %s not in %a" name
      (Fmt.list ~sep:(Fmt.const Fmt.string ", ") Fmt.string)
      expecteds

let v =
  [
    ( "timezone",
      Alcotest.
        [
          test_case "daylight saving" `Quick daylight_savings;
          test_case "timezone_name" `Quick timezone_name;
        ] );
  ]
