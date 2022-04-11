(** Timmy timezone implementation is available in two flavors: using a static
    offset from UTC or by providing an implementation. Providing an
    implementation can be used when the need for accomodating to daylight
    savings is needed (or any other time transition implemented with a timezone
    shift). See {timmy-jsoo} for a native Javascript implementation. *)

(** {1 Type} *)

(** A timezone. *)
type t

(** {1 Construction} *)

(** [of_gmt_offset_seconds s] is a static timezone with offset [s] seconds from
    UTC. UTC + offset = local.*)
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

(** [gmt_offset_seconds_with_datetime tz ~date ~time] is the number of seconds
    that offset from UTC, for the given date (year, month, day) and time (hour,
    minute, second).

    Note: Implementations will struggle with consistency for ambiguous
    dates. As an example: requesting the offset for an hour that is skipped
    during a daylight saving transition will yeild an offset that may not agree
    with {gmt_offset_seconds_with_ptime}.*)
val gmt_offset_seconds_with_datetime :
  t -> date:int * int * int -> time:int * int * int -> int

(** [gmt_offset_seconds_with_ptime tz timestamp] is the number of seconds that
    offset from UTC, at the time given by a unix timestamp (Ptime.t). *)
val gmt_offset_seconds_with_ptime : t -> Ptime.t -> int
