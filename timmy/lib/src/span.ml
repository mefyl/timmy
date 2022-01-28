open Base

module T = struct
  include Type.Span

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

let hours s = Ptime.Span.of_int_s (s * 60 * 60)

let minutes s = Ptime.Span.of_int_s (s * 60)

let seconds s = Ptime.Span.of_int_s s

let to_days s = Ptime.Span.to_d_ps s |> fst

let to_seconds s = Option.value_exn ~here:[%here] (Ptime.Span.to_int_s s)

let pp f s =
  let s = to_seconds s in
  let d = s / (60 * 60 * 24)
  and h = s / (60 * 60) % 24
  and m = s / 60 % 60
  and s = s % 60 in
  let open Fmt in
  let days f = function
    | 0 -> ()
    | 1 -> string f "1 day"
    | n -> pf f "%i days" n
  and hours f = function
    | 0 -> ()
    | n -> pf f "%ih" n
  and minutes f = function
    | 0 -> ()
    | n -> pf f "%im" n
  and seconds f = function
    | 0 -> ()
    | n -> pf f "%is" n
  and sp l r =
    if Int.(l > 0 && r > 0) then
      const char ' '
    else
      nop
  in
  concat ~sep:nop
    [
      const days d;
      sp d h;
      const hours h;
      sp h m;
      const minutes m;
      sp m s;
      const seconds s;
    ]
    f ()

let of_ptime s = s

let to_ptime s = s
