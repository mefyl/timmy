let make (type t) (module O : Alcotest.TESTABLE with type t = t) :
    O.t Alcotest.testable =
  Alcotest.testable O.pp O.equal

let date = make (module Timmy.Date)
let daytime = make (module Timmy.Daytime)
let time = make (module Timmy.Time)
let week = make (module Timmy.Week)
