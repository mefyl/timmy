open Acid

type t =
  | January
  | February
  | March
  | April
  | May
  | June
  | July
  | August
  | September
  | October
  | November
  | December
[@@deriving schema]

let to_int = function
  | January -> 1
  | February -> 2
  | March -> 3
  | April -> 4
  | May -> 5
  | June -> 6
  | July -> 7
  | August -> 8
  | September -> 9
  | October -> 10
  | November -> 11
  | December -> 12

let of_int = function
  | 1 -> Result.return January
  | 2 -> Result.return February
  | 3 -> Result.return March
  | 4 -> Result.return April
  | 5 -> Result.return May
  | 6 -> Result.return June
  | 7 -> Result.return July
  | 8 -> Result.return August
  | 9 -> Result.return September
  | 10 -> Result.return October
  | 11 -> Result.return November
  | 12 -> Result.return December
  | d -> Result.fail (Fmt.str "invalid month: %i" d)

let schema_string = schema

let schema_int =
  let open Schematic.Schema in
  {
    descriptor = Map (of_int, to_int, Int);
    id = Some "month";
    parametric = None;
  }

let schema = schema_int

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

let pp = Fmt.of_to_string to_string
