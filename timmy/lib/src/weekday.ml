open Base

module Type = struct
  include Type_schema.Weekday

  let to_string = function
    | Monday -> "Monday"
    | Tuesday -> "Tuesday"
    | Wednesday -> "Wednesday"
    | Thursday -> "Thursday"
    | Friday -> "Friday"
    | Saturday -> "Saturday"
    | Sunday -> "Sunday"

  let sexp_of_t t = Sexp.Atom (to_string t)
end

include Type

let to_int ?(base = Monday) weekday =
  let to_int = function
    | Monday -> 0
    | Tuesday -> 1
    | Wednesday -> 2
    | Thursday -> 3
    | Friday -> 4
    | Saturday -> 5
    | Sunday -> 6
  in
  Int.rem (to_int weekday - to_int base + 7) 7

let of_int = function
  | 0 -> Some Monday
  | 1 -> Some Tuesday
  | 2 -> Some Wednesday
  | 3 -> Some Thursday
  | 4 -> Some Friday
  | 5 -> Some Saturday
  | 6 -> Some Sunday
  | _ -> None

let increment wd n =
  let k = (to_int wd + n) % 7 in
  let k = if k < 0 then k + 7 else k in
  Option.value_exn ~here:[%here] @@ of_int k

let pp = Fmt.of_to_string to_string

module O = struct
  include Comparable.Make (Type)
end

include O
