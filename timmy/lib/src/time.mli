open Base

(** {1 Type} *)

(** @inline *)
include Type_schema.TIME

(** {1 Construction} *)

(** Timmy leaves the burden of determining the current time to {!Ptime_clock}.
    Pick the right ptime.clock library for your platform and use
    [Timmy.Time.of_ptime (Ptime_clock.now ())]. *)

(** {2 Well known values} *)

(** [epoch] is January 1, 1970 00:00:00 UTC/GMT. *)
val epoch : t

(** {1 Time manipulation} *)

(** {2 Comparison} *)

include Base.Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Base.Comparable.Infix with type t := t

  (** [time + span] is the time point [span] after [time]. *)
  val ( + ) : t -> Span.t -> t

  (** [end - start] is the duration elapsed from [start] to [end]. *)
  val ( - ) : t -> t -> Span.t
end

include module type of O

(** {1 Scalar conversions} *)

(** {2 Pretty-print} *)

(** [pp f date] prints [date] to [f] in an unspecified, human readable format. *)
val pp : t Fmt.t

(** {2 String} *)

(** [to_string time] is the RCF3339 representation of [time], eg. 2021-10-04. *)
val to_string : ?timezone:Timezone.t -> t -> string

(** [of_string s] is the time represented by [s] as per RCF3339 or a relevant
    error message if it is invalid. *)
val of_string : string -> (t, string) Result.t

(** [of_rfc3339] is {!to_string}. *)
val to_rfc3339 : ?timezone:Timezone.t -> t -> string

(** [of_rfc3339] is {!of_string}. *)
val of_rfc3339 : string -> (t, string) Result.t

(** {2 Ptime} *)

(** [of_ptime ptime] is the time equivalent to [ptime]. *)
val of_ptime : Ptime.t -> t

(** [to_ptime time] is the Ptime time equivalent to [time]. *)
val to_ptime : t -> Ptime.t
