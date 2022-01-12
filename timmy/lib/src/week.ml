open Acid

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

let start { n; year } =
  let first = Month.to_date ~year January in
  let offset = -(Date.weekday first |> Weekday.to_int ~base:Friday) - 4 in
  Date.add_days first (offset + (n * 7))

let make ~year n =
  let res = { n; year } in
  let Date.{ month; day; year = start_year } = start res in
  match (n, month) with
  | _ when n < 1 -> Result.failf "week %i is less than 1" n
  | _ when n > 53 -> Result.failf "week %i is greater than 53" n
  | 53, December when day >= 29 -> Result.failf "year %i has no week 53" year
  | _ when start_year <> year -> Result.failf "year %i has no week 53" year
  | _ -> Result.return res

let pp f { n; year } = Fmt.pf f "%04i-%02i" year n

module O = struct
  include Base.Comparable.Make (T)
end

include O
