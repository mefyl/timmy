open Acid

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

(** {2 Time conversions} *)

(** [of_time ~timezone time] is the time of the day at [time] in [timezone]. *)
val of_time : timezone:Timezone.t -> Time.t -> t

(** [to_time ~timezone date daytime] is the time at [daytime] on [date] in
    [timezone]. *)
val to_time : timezone:Timezone.t -> Date.t -> t -> Time.t

(** {2 Comparison} *)

include Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Comparable.Infix with type t := t
end

include module type of O

(** {1 Scalar conversions} *)

(** {2 Pretty-print} *)

(** [pp f daytime] prints [daytime] to [f] in RFC3339 format, eg. 12:43:51. *)
val pp : t Fmt.t

(** {2 Tuple} *)

(** [to_tuple { hours; minutes; seconds }] is [(hours, minutes, seconds)]. *)
val to_tuple : t -> int * int * int

(** [of_tuple (hours, minutes, seconds)] is the corresponding time of the day if
    it is valid or a relevant error message otherwise. *)
val of_tuple : int * int * int -> (t, string) Result.t

(** [of_tuple (hours, minutes, seconds)] is the corresponding time of the day

    @raise Failure if the time of the day is invalid. *)
val of_tuple_exn : here:Source_code_position.t -> int * int * int -> t
