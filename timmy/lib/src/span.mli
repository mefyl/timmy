(** {1 Type} *)

include Type.SPAN
include module type of Type_js.Span

(** {1 Construction} *)

(** [days n] is a duration of [n] days. *)
val days : int -> t

(** [minutes n] is a duration of [n] hours. *)
val hours : int -> t

(** [minutes n] is a duration of [n] minutes. *)
val minutes : int -> t

(** [seconds n] is a duration of [n] seconds. *)
val seconds : int -> t

(** {1 Time manipulation} *)

(** [to_days span] is the number of days in [span] floored. *)
val to_days : t -> int

(** [to_days span] is the number of seconds in [span] floored. *)
val to_seconds : t -> int

(** {2 Comparison} *)

include Base.Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Base.Comparable.Infix with type t := t

  (** [-span] is the opposite of [span]. *)
  val ( ~- ) : t -> t
end

include module type of O

(** {1 Scalar conversions} *)

(** {2 Pretty-print} *)

(** [pp f span] prints [span] to [f] in an unspecified human readable format,
    e.g. 45s or 2h. *)
val pp : t Fmt.t

(** {2 Ptime} *)

(** [of_ptime ptime_span] is the span equivalent to [ptime_span]. *)
val of_ptime : Ptime.Span.t -> t

(** [to_ptime span] is the Ptime span equivalent to [span]. *)
val to_ptime : t -> Ptime.Span.t
