open Base

(** {1 Type} *)

(** @inline *)
include Type.DAYTIME

(** {1 Construction} *)

(** [make ~hours ~minutes ~int] is [{ hours; minutes; seconds }] if it
    represents a valid time of the day or a relevant error message otherwise. *)
val make : hours:int -> minutes:int -> seconds:int -> (t, string) Result.t

(** {2 Well known values} *)

(** [latest] is [{hours = 23; minutes = 59; seconds = 59}] *)
val latest : t

(** [midnight] is [{hours = 0; minutes = 0; seconds = 0}] *)
val midnight : t

(** [noon] is [{hours = 12; minutes = 0; seconds = 0}] *)
val noon : t

(** {1 Time manipulation} *)

(** [with_daytime ~timezone daytime time] is [daytime] time of the day on the
    same date as [time] in [timezone]. *)
val with_daytime : timezone:Timezone.t -> t -> Time.t -> Time.t

(** [truncate_seconds daytime] is [daytime] with seconds set to [0]. *)
val truncate_seconds : t -> t

(** [truncate_minutes daytime] is [daytime] with minutes and seconds set to [0]. *)
val truncate_minutes : t -> t

(** {2 Time conversions} *)

(** [of_time ~timezone time] is the time of the day at [time] in [timezone]. *)
val of_time : timezone:Timezone.t -> Time.t -> t

(** [to_time ~timezone date daytime] is the time at [daytime] on [date] in
    [timezone]. When the [date] and [datetime] do not exist in [timezone]
    because of a time transition (eg. daylight saving), the returned [time] will
    be shifted to an existing hour. The manner in which the shift is applied is
    system dependant. *)
val to_time : timezone:Timezone.t -> Date.t -> t -> Time.t

(** {2 Comparison} *)

include Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Comparable.Infix with type t := t

  (** [daytime + span] is the daytime after [span] has elapsed, or a relevant
      error message if the result is out of bounds. *)
  val ( + ) : t -> Span.t -> (t, string) Result.t
end

include module type of O

(** {1 Scalar conversions} *)

(** {2 Integer} *)

(** [to_int daytime] the number of seconds from midnight to [daytime]. *)
val to_int : t -> int

(** [of_int n] the daytime [n] seconds after midnight or a relevant error
    message if the result is out of bounds. *)
val of_int : int -> (t, string) Result.t

(** {2 Pretty-print} *)

(** [pp f daytime] prints [daytime] to [f] in RFC3339 format, eg. 12:43:51. *)
val pp : t Fmt.t

(** [pp_opt ~format ~precision ~size () f daytime] pretty-prints [daytime] to
    [f] according to the given options.

    - [format]: [`_12] prints in a US-style twelve hour format (eg. [12AM],
      [1:30AM], [12PM], [1:30PM]), [`_24] prints in twelve twenty-four hour
      format (eg. [00:00], [1:30], [12:00], [13:30]). Default is [`_24].
    - [precision]: [`Hours] displays only hours (eg. [1PM], [13]), [`Minutes]
      also displays minutes (eg. [13:42], [1:42PM]) and [`Seconds] additionally
      displays seconds (eg. [13:42:51], [1:42:51PM]). Default is [`Seconds].
    - [size]: [`Long] displays null minutes and seconds (eg. [12:42:00],
      [13:00:00]) while [`Short] omits them (eg. [12:42], [13]). Default is
      [`Short]. *)
val pp_opt :
  ?format:[ `_12 | `_24 ] ->
  ?precision:[ `Hours | `Minutes | `Seconds ] ->
  ?size:[ `Long | `Short ] ->
  unit ->
  t Fmt.t

(** {2 Tuple} *)

(** [to_tuple { hours; minutes; seconds }] is [(hours, minutes, seconds)]. *)
val to_tuple : t -> int * int * int

(** [of_tuple (hours, minutes, seconds)] is the corresponding time of the day if
    it is valid or a relevant error message otherwise. *)
val of_tuple : int * int * int -> (t, string) Result.t

(** [of_tuple (hours, minutes, seconds)] is the corresponding time of the day

    @raise Failure if the time of the day is invalid. *)
val of_tuple_exn : here:Source_code_position.t -> int * int * int -> t
