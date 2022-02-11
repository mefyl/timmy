open Base

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
  (** A month.

      @canonical Timmy.Month.t *)
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
    let ( let* ) = Result.( >>= ) in
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

module Daytime = struct
  type t = {
    hours : int;
    minutes : int;
    seconds : int;
  }
  [@@deriving ord]

  let make ~hours ~minutes ~seconds =
    let ( let* ) = Result.( >>= ) in
    let* () =
      if hours >= 0 && hours < 24 then Result.return ()
      else Result.failf "invalid hours: %i" hours
    in
    let* () =
      if minutes >= 0 && minutes < 60 then Result.return ()
      else Result.failf "invalid minutes: %i" hours
    in
    let* () =
      if seconds >= 0 && seconds < 60 then Result.return ()
      else Result.failf "invalid seconds: %i" hours
    in
    Result.return { hours; minutes; seconds }

  let to_tuple { hours; minutes; seconds } = (hours, minutes, seconds)
end

module type DAYTIME = sig
  (** A time of the day. *)
  type t = private {
    hours : int;
    minutes : int;
    seconds : int;
  }
end

module Span = struct
  type t = Ptime.Span.t
end

module type SPAN = sig
  (** A duration.

      Spans may be negative. *)
  type t
end

module Time = struct
  type t = Ptime.t
end

module type TIME = sig
  (** A point in time. *)
  type t
end

module Week = struct
  type t = {
    n : int;
    year : int;
  }
end

module type WEEK = sig
  (** A week of a year.

      Per ISO 8601 week date system, a week is attributed to the year its
      Thursday is in.*)
  type t = private {
    n : int;
    year : int;
  }
end

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
