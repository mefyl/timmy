open Base
include Span_intf

module T = struct
  type t = Ptime.Span.t

  let compare = Ptime.Span.compare

  let sexp_of_t s = Sexp.Atom (Fmt.str "%a" Ptime.Span.pp s)
end

include T

module O = struct
  include Comparable.Make (T)

  let ( ~- ) = Ptime.Span.neg
end

include O

let days s = Option.value_exn ~here:[%here] (Ptime.Span.of_d_ps (s, 0L))

let seconds s = Ptime.Span.of_int_s s

let to_days s = Ptime.Span.to_d_ps s |> fst

let to_seconds s = Option.value_exn ~here:[%here] (Ptime.Span.to_int_s s)

let of_ptime s = s

let to_ptime s = s
