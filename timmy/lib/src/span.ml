open Base

module T = struct
  include Type.Span

  let compare = Ptime.Span.compare
  let sexp_of_t s = Sexp.Atom (Fmt.str "%a" Ptime.Span.pp s)
end

include T
include Type_js.Span

let days s = Option.value_exn ~here:[%here] (Ptime.Span.of_d_ps (s, 0L))
let hours s = Ptime.Span.of_int_s (s * 60 * 60)
let minutes s = Ptime.Span.of_int_s (s * 60)
let seconds s = Ptime.Span.of_int_s s
let to_days s = Ptime.Span.to_d_ps s |> fst
let to_seconds s = Option.value_exn ~here:[%here] (Ptime.Span.to_int_s s)

module O = struct
  include Comparable.Make (T)

  let ( / ) l r = to_seconds l / to_seconds r
  let ( + ) = Ptime.Span.add
  let ( - ) = Ptime.Span.sub
  let ( ~- ) = Ptime.Span.neg

  let ( *. ) span m =
    (span |> Ptime.Span.to_float_s) *. m
    |> Ptime.Span.of_float_s
    |> Base.Option.value_exn ~here:[%here]

  let ( * ) span m = span *. Int.to_float m
end

let pp f span =
  let span = to_seconds span in
  let span_abs = Int.abs span in
  let d = span_abs / (60 * 60 * 24)
  and h = span_abs / (60 * 60) % 24
  and m = span_abs / 60 % 60
  and s = span_abs % 60 in
  let open Fmt in
  let days f = function
    | 0 -> ()
    | 1 -> string f "1 day"
    | n -> pf f "%i days" n
  and hours f = function 0 -> () | n -> pf f "%ih" n
  and minutes f = function 0 -> () | n -> pf f "%im" n
  and seconds f = function 0 -> () | n -> pf f "%is" n
  and sp l r = if Int.(l > 0 && r > 0) then const char ' ' else nop in
  concat ~sep:nop
    [
      (if Int.(span < 0) then const char '-' else nop);
      const days d;
      sp d h;
      const hours h;
      sp h m;
      const minutes m;
      sp m s;
      const seconds s;
    ]
    f ()

include O

let of_ptime s = s
let to_ptime s = s
