module Date = struct
  type js = Js_of_ocaml.Js.date Js_of_ocaml.Js.t
end

module Daytime = struct
  type js =
    < hours : Js_of_ocaml.Js.number Js_of_ocaml.Js.readonly_prop
    ; minutes : Js_of_ocaml.Js.number Js_of_ocaml.Js.readonly_prop
    ; seconds : Js_of_ocaml.Js.number Js_of_ocaml.Js.readonly_prop >
    Js_of_ocaml.Js.t
end

module Time = struct
  (** Time representation in javascript. *)
  type js = Js_of_ocaml.Js.date Js_of_ocaml.Js.t
end

module Week = struct
  type js =
    < n : Js_of_ocaml.Js.number Js_of_ocaml.Js.readonly_prop
    ; year : Js_of_ocaml.Js.number Js_of_ocaml.Js.readonly_prop >
    Js_of_ocaml.Js.t
end
