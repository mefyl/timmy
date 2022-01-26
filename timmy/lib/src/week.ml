open Base

module T = struct
  include Type.Week

  let sexp_of_t { n; year } =
    Sexp.List [ Sexp.Atom (Int.to_string year); Sexp.Atom (Int.to_string n) ]

  let compare (l : t) (r : t) =
    match Int.compare l.year r.year with
    | 0 -> Int.compare l.n r.n
    | ord -> ord
end

include T
include Type_js.Week

let to_date { n; year } =
  let first = Month.to_date ~year January in
  let offset = -(Date.weekday first |> Weekday.to_int ~base:Friday) - 4 in
  Date.(to_int first) + offset + (n * 7)

let _year week =
  let Date.{ month; day; year } = to_date week |> Date.of_int in
  match month with
  | December when day >= 29 -> year + 1
  | _ -> year

let make ~year n =
  let res = { n; year } in
  if n < 1 then
    Result.failf "week %i is less than 1" n
  else if n > 53 then
    Result.failf "week %i is greater than 53" n
  else if _year res <> year then
    Result.failf "year %i has no week 53" year
  else
    Result.return res

let of_monday jd =
  let Date.{ day; month; year } = Date.of_int jd in
  match month with
  | December when day >= 29 -> { n = 1; year = year + 1 }
  | _ -> { n = ((jd - to_date { n = 1; year }) / 7) + 1; year }

let of_date d = of_monday @@ (Date.to_int d - (Date.weekday d |> Weekday.to_int))

let to_date week = Date.of_int @@ to_date week

let days week =
  Base.Sequence.unfold
    ~init:(to_date week, 0)
    ~f:(function
      | _, 7 -> None
      | date, n -> Some (Date.(date + n), (date, n + 1)))

let pp f { n; year } = Fmt.pf f "%04i-%02i" year n

module O = struct
  include Base.Comparable.Make (T)

  let ( + ) week count =
    (Date.to_int @@ to_date week) + (count * 7) |> of_monday
end

include O

let to_string = Fmt.to_to_string pp

let of_string s =
  match String.split ~on:'-' s with
  | [ year; week ] -> (
    try make ~year:(Int.of_string year) (Int.of_string week) with
    | _ -> Result.failf "invalid number in date: %S" s)
  | _ -> Result.failf "invalid date format: %S" s
