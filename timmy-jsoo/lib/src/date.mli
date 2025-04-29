include module type of Timmy.Date

val to_js : Timmy.Date.t -> Js_of_ocaml.Js.date Js_of_ocaml.Js.t
val of_js : Js_of_ocaml.Js.date Js_of_ocaml.Js.t -> Timmy.Date.t
