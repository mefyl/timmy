module Month = struct
  (** @canonical Timmy.Month.t *)
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
    | 1 -> Result.Ok January
    | 2 -> Result.Ok February
    | 3 -> Result.Ok March
    | 4 -> Result.Ok April
    | 5 -> Result.Ok May
    | 6 -> Result.Ok June
    | 7 -> Result.Ok July
    | 8 -> Result.Ok August
    | 9 -> Result.Ok September
    | 10 -> Result.Ok October
    | 11 -> Result.Ok November
    | 12 -> Result.Ok December
    | d -> Base.Result.failf "invalid month: %i" d

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
  (** A date.

      @canonical Timmy.Date.t *)
  type t = {
    day : int;  (** The day of the month. *)
    month : Month.t;  (** The month of the year. *)
    year : int;  (** The year. *)
  }

  let pp fmt { day; month; year } =
    Fmt.pf fmt "%04i-%02i-%02i" year (Month.to_int month) day

  let to_tuple { day; month; year } = (year, Month.to_int month, day)

  let of_tuple ((year, month, day) as date) =
    let ( let* ) = Base.Result.( >>= ) in
    let* month = Month.of_int month in
    match Ptime.of_date date with
    | Some _ -> Result.Ok { year; month; day }
    | None -> Result.Error (Fmt.str "invalid date: %a" pp { year; month; day })
end

module type DATE = sig
  (** A date.

      @canonical Timmy.Date.t *)
  type t = private {
    day : int;  (** The day of the month. *)
    month : Month.t;  (** The month of the year. *)
    year : int;  (** The year. *)
  }
end

module Daytime = struct
  (** @canonical Timmy.Daytime.t *)
  type t = {
    hours : int;
    minutes : int;
    seconds : int;
  }
  [@@deriving ord]

  let make ~hours ~minutes ~seconds =
    let ( let* ) = Base.Result.( >>= ) in
    let* () =
      if hours >= 0 && hours < 24 then Result.Ok ()
      else Base.Result.failf "invalid hours: %i" hours
    in
    let* () =
      if minutes >= 0 && minutes < 60 then Result.Ok ()
      else Base.Result.failf "invalid minutes: %i" hours
    in
    let* () =
      if seconds >= 0 && seconds < 60 then Result.Ok ()
      else Base.Result.failf "invalid seconds: %i" hours
    in
    Result.Ok { hours; minutes; seconds }

  let to_tuple { hours; minutes; seconds } = (hours, minutes, seconds)
end

module type DAYTIME = sig
  (** A time of the day.

      @canonical Timmy.Daytime.t *)
  type t = private {
    hours : int;
    minutes : int;
    seconds : int;
  }
end

module Span = struct
  (** @canonical Timmy.Span.t *)
  type t = Ptime.Span.t
end

module type SPAN = sig
  (** A duration.

      Spans may be negative.

      @canonical Timmy.Span.t *)
  type t
end

module Time = struct
  (** @canonical Timmy.Time.t *)
  type t = Ptime.t
end

module type TIME = sig
  (** A point in time.

      @canonical Timmy.Time.t *)
  type t
end

module Week = struct
  (** @canonical Timmy.Week.t *)
  type t = {
    n : int;
    year : int;
  }
end

module type WEEK = sig
  (** A week of a year.

      Per ISO 8601 week date system, a week is attributed to the year its
      Thursday is in.

      @canonical Timmy.Week.t *)
  type t = private {
    n : int;
    year : int;
  }
end

module Weekday = struct
  (** @canonical Timmy.Weekday.t *)
  type t =
    | Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday
  [@@deriving eq, ord]
end

module type WEEKDAY = sig
  (** A day of the week.

      @canonical Timmy.Weekday.t *)
  type t =
    | Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday
end
