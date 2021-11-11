open Acid

module Month = struct
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
  [@@deriving ord]

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
end

module type MONTH = sig
  (** A month. *)
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
end

module Date = struct
  (** A date. *)
  type t = {
    day : int;  (** The day of the month. *)
    month : Month.t;  (** The month of the year. *)
    year : int;  (** The year. *)
  }

  let pp fmt { day; month; year } =
    Fmt.pf fmt "%04i-%02i-%02i" year (Month.to_int month) day

  let to_tuple { day; month; year } = (year, Month.to_int month, day)

  let of_tuple ((year, month, day) as date) =
    let open Let.Syntax2 (Result) in
    let* month = Month.of_int month in
    match Ptime.of_date date with
    | Some _ -> Result.Ok { year; month; day }
    | None -> Result.Error (Fmt.str "invalid date: %a" pp { year; month; day })
end

module type DATE = sig
  (** A date. *)
  type t = private {
    day : int;  (** The day of the month. *)
    month : Month.t;  (** The month of the year. *)
    year : int;  (** The year. *)
  }
end

module Time = struct
  (** A point in time. *)
  type t = Ptime.t
end

module type TIME = module type of Time

module Weekday = struct
  type t =
    | Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday
  [@@deriving eq]
end

module type WEEKDAY = sig
  (** A day of the week. *)
  type t =
    | Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday
end
