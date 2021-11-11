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
module O = Comparable.Make (Type)
include O

let pp = Fmt.of_to_string to_string
