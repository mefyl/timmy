open Base
include Time_intf

module T = struct
  type t = Ptime.t [@@schematic.name "time"] [@@deriving schema]

  type js = Js_of_ocaml.Js.date Js_of_ocaml.Js.t

  let compare = Ptime.compare

  let sexp_of_t t = Sexp.Atom (Ptime.to_rfc3339 t)
end

module Infix = struct
  include Comparable.Make (T)

  let ( - ) l r = Ptime.diff l r |> Span.of_ptime
end

include T
include Infix

let of_ptime t = t

let to_ptime t = t

let pp = Ptime.pp

module O = Infix
