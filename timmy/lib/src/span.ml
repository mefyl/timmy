open Base

module T = struct
  include Type_schema.Span

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

  let ( /. ) l r = Ptime.Span.to_float_s l /. Ptime.Span.to_float_s r
  let ( / ) l r = l /. r |> Float.to_int
  let ( + ) = Ptime.Span.add
  let ( - ) = Ptime.Span.sub
  let ( ~- ) = Ptime.Span.neg

  let ( *. ) span m =
    let span = (span |> Ptime.Span.to_float_s) *. m |> Ptime.Span.of_float_s in
    Base.Option.value_exn ~here:[%here] span

  let ( * ) span m = span *. Int.to_float m
end

let pico = 1000000000000L

let pp f span =
  let negative, days, ps =
    let days, ps = Ptime.Span.to_d_ps span in
    if days >= 0 then (false, days, ps)
    else if Int64.(ps = 0L) then (true, -days, 0L)
    else (true, -(days + 1), Int64.(neg @@ (ps - (pico * 60L * 60L * 24L))))
  in
  let open Fmt in
  if days = 0 && Int64.(ps < 1000000000L) then string f "0s"
  else
    let d = Int.abs days
    and h = Int64.(ps / (pico * 60L * 60L) % 24L) |> Int64.to_int_trunc
    and m = Int64.(ps / (pico * 60L) % 60L) |> Int64.to_int_trunc
    and s = Int64.(ps / pico % 60L) |> Int64.to_int_trunc
    and ms = Int64.(ps / 1000000000L % 1000L) |> Int64.to_int_trunc in
    let days f = function
      | 0 -> ()
      | 1 -> string f "1 day"
      | n -> pf f "%i days" n
    and hours f = function 0 -> () | n -> pf f "%ih" n
    and minutes f = function 0 -> () | n -> pf f "%im" n
    and seconds f = function
      | 0, 0 -> ()
      | s, 0 -> pf f "%is" s
      | s, ms -> pf f "%d.%03ds" s ms
    and sp c l r = if Int.(l > 0 && r > 0) then const char c else nop in
    concat ~sep:nop
      [
        (if negative then const char '-' else nop);
        const days d;
        sp ' ' d h;
        const hours h;
        sp ' ' h m;
        const minutes m;
        sp ' ' m s;
        const seconds (s, ms);
      ]
      f ()

include O

let of_ptime s = s
let to_ptime s = s
