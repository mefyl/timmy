open Acid

module T = struct
  type t = {
    day : int;
    month : int;
    year : int;
  }

  let pp fmt { day; month; year } = Fmt.pf fmt "%04i-%02i-%02i" year month day

  let to_tuple { day; month; year } = (year, month, day)

  let to_sexp_tuple (y, m, d) =
    Sexp.List
      [
        Sexp.Atom (Int.to_string y);
        Sexp.Atom (Int.to_string m);
        Sexp.Atom (Int.to_string d);
      ]

  let int_of_string msg s =
    try Result.return @@ Int.of_string s with
    | _ -> Result.failf "invalid %s: %s" msg s

  let of_tuple ((year, month, day) as date) =
    match Ptime.of_date date with
    | Some _ -> Result.Ok { year; month; day }
    | None -> Result.Error (Fmt.str "invalid date: %a" pp { year; month; day })

  let of_string s =
    match String.split ~on:'-' s with
    | [ y; m; d ] ->
      let open Let.Syntax2 (Result) in
      let* y = int_of_string "year" y
      and* m = int_of_string "month" m
      and* d = int_of_string "day" d in
      of_tuple (y, m, d)
    | _ -> Result.fail Fmt.(str "invalid date: %s" s)

  let of_tuple_exn ~here date =
    match of_tuple date with
    | Result.Error _ ->
      Error.raise (Error.create ~here "invalid date" date to_sexp_tuple)
    | Result.Ok d -> d

  let schema =
    Schematic.Schema.(make ~id:"date" (Map (of_tuple, to_tuple, Date)))

  let to_sexp { year; month; day } = to_sexp_tuple (year, month, day)

  let compare l r = Poly.compare (to_tuple l) (to_tuple r)

  let sexp_of_t = to_sexp
end

include Type
include T

(* Shamelessly stolen from ptime *)
let jd_to_date jd =
  let a = jd + 32044 in
  let b = ((4 * a) + 3) / 146097 in
  let c = a - (146097 * b / 4) in
  let d = ((4 * c) + 3) / 1461 in
  let e = c - (1461 * d / 4) in
  let m = ((5 * e) + 2) / 153 in
  let day = e - (((153 * m) + 2) / 5) + 1 in
  let month = m + 3 - (12 * (m / 10)) in
  let year = (100 * b) + d - 4800 + (m / 10) in
  { year; month; day }

(* Shamelessly stolen from ptime *)
let jd_of_date { year; month; day } =
  let a = (14 - month) / 12 in
  let y = year + 4800 - a in
  let m = month + (12 * a) - 3 in
  day
  + (((153 * m) + 2) / 5)
  + (365 * y) + (y / 4) - (y / 100) + (y / 400) - 32045

let add_days date days = jd_to_date @@ (jd_of_date date + days)

(* Shamelessly stolen from ptime, which does not intend on exposing it publicly *)
let max_month_day =
  (* max day number in a given year's month. *)
  let is_leap_year y =
    Int.rem y 4 = 0 && (Int.rem y 100 <> 0 || Int.rem y 400 = 0)
  in
  let mlen =
    [| 31; 28 (* or not *); 31; 30; 31; 30; 31; 31; 30; 31; 30; 31 |]
  in
  fun y m ->
    if m = 2 && is_leap_year y then
      29
    else
      mlen.(m - 1)

module O = struct
  include Base.Comparable.Make (T)

  let ( - ) l r =
    Option.value_exn ~here:[%here]
      (Ptime.Span.of_d_ps (jd_of_date l - jd_of_date r, 0L))
    |> Span.of_ptime
end

let make ~year ~month ~day = of_tuple (year, month, day)

let make_overflow ?(day_truncate = false) ~year ~month ~day () =
  let open Base.Int in
  let adjust_month year month =
    (year + ((month - 1) /% 12), ((month - 1) % 12) + 1)
  in
  let year, month = adjust_month year month in
  if day_truncate then
    { year; month; day = max 1 @@ min day (max_month_day year month) }
  else
    let rec adjust year month day =
      if day <= 0 then
        let year, month = adjust_month year (month - 1) in
        let offset = max_month_day year month in
        adjust year month (day + offset)
      else
        let max = max_month_day year month in
        if day <= max then
          { year; month; day }
        else
          let year, month = adjust_month year (month + 1) in
          adjust year month (day - max)
    in
    adjust year month day

include O

let of_time ~timezone t =
  of_tuple_exn ~here:[%here]
  @@ fst
  @@ Ptime.to_date_time ~tz_offset_s:(Timezone.to_gmt_offset_seconds timezone)
  @@ Time.to_ptime t

let to_time ~timezone t =
  Option.value_exn ~here:[%here]
    (Ptime.of_date_time
       (to_tuple t, ((0, 0, 0), Timezone.to_gmt_offset_seconds timezone)))
  |> Time.of_ptime

let to_string = Fmt.to_to_string pp

let weekday d =
  Ptime.weekday @@ Time.to_ptime @@ to_time ~timezone:Timezone.utc d
