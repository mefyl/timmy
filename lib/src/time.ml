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

let of_string s =
  match Ptime.of_rfc3339 ~strict:true s with
  | Result.Ok (time, _, _) -> Result.Ok time
  | Result.Error (`RFC3339 (_, e)) ->
    Result.fail Fmt.(str "invalid date: %a" Ptime.pp_rfc3339_error e)

let to_ptime t = t

let pp = Ptime.pp

let to_string = Fmt.to_to_string pp

module O = Infix
