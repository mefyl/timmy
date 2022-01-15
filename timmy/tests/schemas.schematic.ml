open Base
open Testable

let json = Alcotest.testable Schematic.Json.pp Schematic.Json.equal

let json () =
  let roundtrip test schema v expected =
    let j = Schematic.Json.encode schema v in
    let () = Alcotest.(check json "JSON representation" expected j) in
    match Schematic.Json.decode schema j with
    | Result.Error e -> Alcotest.(fail (Schematic.Error.decoding_to_string e))
    | Result.Ok decoded -> Alcotest.(check test "decoded value" v decoded)
  in
  let () =
    roundtrip time Timmy.Time.schema
      (Result.ok_or_failwith @@ Timmy.Time.of_string "2021-11-11T18:17:55+01:00")
      (`String "2021-11-11T17:17:55-00:00")
  and () =
    roundtrip date Timmy.Date.schema
      (Result.ok_or_failwith @@ Timmy.Date.of_string "2021-11-12")
      (`A [ `Float 2021.; `Float 11.; `Float 12. ])
  in
  ()

let tests = [ Alcotest.test_case "json" `Quick json ]
