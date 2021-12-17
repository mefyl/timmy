open Acid

module Type = struct
  include Type.Month

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

let add_months m n =
  ((to_int m + n - 1) % 12) + 1 |> of_int |> Result.ok_or_failwith

module O = struct
  include Comparable.Make (Type)

  let ( + ) = add_months
end

include O

let pp = Fmt.of_to_string to_string
