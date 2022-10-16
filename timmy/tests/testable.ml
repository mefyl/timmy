let date = Alcotest.testable Timmy.Date.pp Timmy.Date.equal
let daytime = Alcotest.testable Timmy.Daytime.pp Timmy.Daytime.equal

let decoding_error =
  Alcotest.testable Schematic.Error.pp_decoding Schematic.Error.equal_decoding

let time = Alcotest.testable Timmy.Time.pp Timmy.Time.equal
