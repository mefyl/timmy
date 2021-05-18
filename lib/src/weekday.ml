type t =
  [ `Mon
  | `Tue
  | `Wed
  | `Thu
  | `Fri
  | `Sat
  | `Sun
  ]

let to_int ?(base = `Mon) weekday =
  let to_int = function
    | `Mon -> 0
    | `Tue -> 1
    | `Wed -> 2
    | `Thu -> 3
    | `Fri -> 4
    | `Sat -> 5
    | `Sun -> 6
  in
  (to_int weekday - to_int base + 7) mod 7
