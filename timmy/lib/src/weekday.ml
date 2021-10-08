open Acid

type t =
  | Monday
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday
[@@deriving eq, schema]

let schema_string = schema

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

let to_string = function
  | Monday -> "Monday"
  | Tuesday -> "Tuesday"
  | Wednesday -> "Wednesday"
  | Thursday -> "Thursday"
  | Friday -> "Friday"
  | Saturday -> "Saturday"
  | Sunday -> "Sunday"

let pp = Fmt.of_to_string to_string

module O = struct
  let ( = ) l r = equal l r

  let ( <> ) l r = not (l = r)
end

include O
