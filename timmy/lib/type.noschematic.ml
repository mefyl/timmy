[@@@warning "-unused-value-declaration"]

module type DATE = Types_bare.DATE with type t = Types_bare.Date.t

module Date = Types_bare.Date

module type DAYTIME = Types_bare.DAYTIME

module Daytime = Types_bare.Daytime

module type MONTH = Types_bare.MONTH

module Month = Types_bare.Month

module type SPAN = Types_bare.SPAN

module Span = Types_bare.Span

module type TIME = Types_bare.TIME

module Time = Types_bare.Time

module type WEEK = Types_bare.WEEK

module Week (Make : sig
  val make : year:int -> int -> (Types_bare.Week.t, string) Result.t
end) =
  Types_bare.Week

module type WEEKDAY = Types_bare.WEEKDAY

module Weekday = Types_bare.Weekday
