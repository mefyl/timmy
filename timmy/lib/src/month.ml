open Base

module Type = struct
  include Type_schema.Month

  let to_string = function
    | January -> "January"
    | February -> "February"
    | March -> "March"
    | April -> "April"
    | May -> "May"
    | June -> "June"
    | July -> "July"
    | August -> "August"
    | September -> "September"
    | October -> "October"
    | November -> "November"
    | December -> "December"

  let sexp_of_t t = Sexp.Atom (to_string t)
end

include Type
include Type_js.Month

let of_string m =
  match String.lowercase m with
  | "january" -> Result.Ok January
  | "february" -> Result.Ok February
  | "march" -> Result.Ok March
  | "april" -> Result.Ok April
  | "may" -> Result.Ok May
  | "june" -> Result.Ok June
  | "july" -> Result.Ok July
  | "august" -> Result.Ok August
  | "september" -> Result.Ok September
  | "october" -> Result.Ok October
  | "november" -> Result.Ok November
  | "december" -> Result.Ok December
  | s -> Result.failf "invalid month name: %s" s

let add_months m n =
  ((to_int m + n - 1) % 12) + 1 |> of_int |> Result.ok_or_failwith

let to_date ~year month =
  Types_bare.Date.of_tuple (year, to_int month, 1) |> Result.ok_or_failwith

let days ~year month =
  let month = to_int month in
  let f i =
    match Types_bare.Date.of_tuple (year, month, i) with
    | Result.Ok date -> Some (date, i + 1)
    | Result.Error _ -> None
  in
  Base.Sequence.unfold ~init:1 ~f

module O = struct
  include Comparable.Make (Type)

  let ( + ) = add_months
end

include O

let pp = Fmt.of_to_string to_string
