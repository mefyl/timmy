type t =
  | Monday
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday

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
  (to_int weekday - to_int base + 7) mod 7
