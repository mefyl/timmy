(** Timmy can only represent static timezones with a fixed offset from UTC. To
    accomodate for an evolving timezone -- eg. daylight saving time -- one must
    recompute the current timezone regularly and pass an updated value to
    {!Timmy}.*)

(** {1 Type} *)

(** A static timezone with a fixed offset from UTC. *)
type t

(** {1 Construction} *)

(** Timmy leaves the burden of determining the local time to {!Ptime_clock}.
    Pick the right ptime.clock library for your platform and use
    [Ptime_clock.current_tz_offset_s] in conjunction with
    [Timmy.Timezone.of_gmt_offset_seconds]. *)

(** [of_gmt_offset_seconds s] is the timezone offset by [s] seconds from UTC. *)
val of_gmt_offset_seconds : int -> t

(** [to_gmt_offset_seconds tz] is the number of seconds [tz] is offset from UTC. *)
val to_gmt_offset_seconds : t -> int

(** {2 Well known values} *)

(** [utc] is the UTC timezone. *)
val utc : t
