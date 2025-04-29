include module type of Timmy.Time

val to_js : t -> Js_of_ocaml.Js.date Js_of_ocaml.Js.t
val of_js : Js_of_ocaml.Js.date Js_of_ocaml.Js.t -> t
