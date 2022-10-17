open Base
open Testable

let json = Alcotest.testable Schematic.Json.pp Schematic.Json.equal

let decoding_error =
  Alcotest.testable Schematic.Error.pp_decoding Schematic.Error.equal_decoding

let roundtrip ~here test schema v expected =
  let j = Schematic.Json.encode schema v in
  let () = Alcotest.(check ~here json "JSON representation" expected j) in
  match Schematic.Json.decode schema j with
  | Result.Error e ->
    Alcotest.(fail ~here (Schematic.Error.decoding_to_string e))
  | Result.Ok decoded -> Alcotest.(check ~here test "decoded value" v decoded)

let json () =
  let () =
    roundtrip ~here:[%here] time Timmy.Time.schema
      (Result.ok_or_failwith @@ Timmy.Time.of_string "2021-11-11T18:17:55+01:00")
      (`String "2021-11-11T17:17:55-00:00")
  and () =
    roundtrip ~here:[%here] date Timmy.Date.schema
      (Result.ok_or_failwith @@ Timmy.Date.of_string "2021-11-12")
      (`A [ `Float 2021.; `Float 11.; `Float 12. ])
  in
  ()

let daytime () =
  let () =
    roundtrip ~here:[%here] daytime Timmy.Daytime.schema
      (Result.ok_or_failwith
      @@ Timmy.Daytime.make ~hours:13 ~minutes:37 ~seconds:42)
      (`O
        [
          ("hours", `Float 13.); ("minutes", `Float 37.); ("seconds", `Float 42.);
        ])
  and () =
    let res =
      Schematic.Json.decode Timmy.Daytime.schema
        (`O
          [
            ("hours", `Float (-1.));
            ("minutes", `Float 0.);
            ("seconds", `Float 0.);
          ])
    in
    Alcotest.(
      check ~here:[%here]
        (result daytime decoding_error)
        "invalid daytime"
        (Result.Error
           Schematic.Error.
             {
               schema = Some "daytime";
               path = [];
               reason = "invalid hours: -1";
             })
        res)
  in
  ()

let tests =
  [
    Alcotest.test_case "json" `Quick json;
    Alcotest.test_case "daytime" `Quick daytime;
  ]
