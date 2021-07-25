include Timmy.Date
module Js = Js_of_ocaml.Js

let to_js { year; month; day } = new%js Js.date_day year Stdlib.(month - 1) day

let of_js (js : Js.date Js.t) =
  Timmy.Date.of_tuple_exn ~here:[%here]
    (js##getFullYear, js##getMonth + 1, js##getDate)