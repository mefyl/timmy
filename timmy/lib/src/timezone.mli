(** Timmy timezone implementation is available in two flavors: one static and
    one system dependant. The static one can be created as an offset from UTC.
    The native one will bind to the underlying system to accomodate for daylight
    savings (or any other time transition implemented with a timezone shift).*)

(** {1 Type} *)

(** A timezone. *)
type t

(** {1 Construction} *)

(** [of_gmt_offset_seconds s] is a static timezone with offset [s] seconds from
    UTC.*)
val of_gmt_offset_seconds : int -> t

(** [of_implementation ~offset_calendar_time_s ~offset_timestamp_s] builds a
    timezone by providing an implementation of the offset computation fromt a
    date and from a timestamp (in seconds)*)
val of_implementation :
  offset_calendar_time_s:(date:int * int * int -> time:int * int * int -> int) ->
  offset_timestamp_s:(unix_timestamp:int -> int) ->
  t

(** [utc] is the UTC timezone.*)
val utc : t

(** {1 Usage} *)

(** When the timezone was created using [native] the offset depends on the given
    time. It includes daylight savings where it applies. Static timezones yield
    the same offset regardless of given time. *)

(** [gmt_offset_seconds_with_datetime tz ~date ~time] is the number of seconds
    that offset from UTC, for the given day (year, month, day) and time (hour,
    minute, second).

    @raise Failure
      if the native implementation finds that [date] and [time] do not exist in
      [tz]. *)
val gmt_offset_seconds_with_datetime :
  t -> date:int * int * int -> time:int * int * int -> int

(** [gmt_offset_seconds_with_ptime tz timestamp] is the number of seconds that
    offset from UTC at the time given by a unix timestamp (Ptime.t).

    @raise Failure
      if the native implementation finds that the [timestamp] do not exist in
      [tz]. *)
val gmt_offset_seconds_with_ptime : t -> Ptime.t -> int
