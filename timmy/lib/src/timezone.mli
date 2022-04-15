(** A [Timezone.t] maps local time to universal time and inversely by providing
    the offset in seconds between UTC and local time. This offset is dependent
    on the date, to accommodate for timezones with daylight saving times. *)

(** {1 Type} *)

(** A timezone. *)
type t

(** {1 Construction} *)

(** [of_gmt_offset_seconds s] is a timezone with a fixed offset of [s] seconds
    from UTC. In other words, [localtime = UTC + offset].*)
val of_gmt_offset_seconds : int -> t

(** [of_implementation ~offset_calendar_time_s ~offset_timestamp_s] builds a
    timezone by providing an implementation of the offset computation from both
    a date and a timestamp (in seconds). *)
val of_implementation :
  offset_calendar_time_s:(date:int * int * int -> time:int * int * int -> int) ->
  offset_timestamp_s:(unix_timestamp:int -> int) ->
  t

(** [utc] is the UTC timezone.*)
val utc : t

(** {1 Usage} *)

(** [gmt_offset_seconds_at_datetime tz ~date ~time] is the number of seconds
    that offset from UTC, for the given date (year, month, day) and time (hour,
    minute, second).

    Note: In case of an ambiguous date, any of the two valid [Time.t] will be
    picked depending on the implementation.*)
val gmt_offset_seconds_at_datetime :
  t -> date:int * int * int -> time:int * int * int -> int

(** [gmt_offset_seconds_at_time tz timestamp] is the number of seconds that
    offset from UTC, at the time given by a unix timestamp (Ptime.t). In other
    words, [localtime = UTC + offset]. *)
val gmt_offset_seconds_at_time : t -> Ptime.t -> int
