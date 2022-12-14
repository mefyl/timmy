(** [now ()] is the current POSIX time, as returned by [Ptime_clock.now ()]. *)
val now : unit -> Timmy.Time.t

(** [timezone_local] is the local timezone. *)
val timezone_local : Timmy.Timezone.t

(** [today ()] is the current date in the local timezone. *)
val today : unit -> Timmy.Date.t
