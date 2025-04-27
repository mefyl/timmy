(** {1 Type} *)

include Type_schema.SPAN

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

  (** [-span]'s duration is the opposite of [span]'s duration. *)
  val ( ~- ) : t -> t

  (** [l + r]'s duration is the sum of [l]'s duration and [r]'s duration. *)
  val ( + ) : t -> t -> t

  (** [l + r]'s duration is the difference between [l]'s duration and [r]'s
      duration. *)
  val ( - ) : t -> t -> t

  (** [span * f]'s duration is [f] times [span]'s duration. *)
  val ( *. ) : t -> float -> t

  (** [span * i]'s duration is [i] times [span]'s duration. *)
  val ( * ) : t -> int -> t

  (** [l / r] is [l]'s duration divided by [r]'s duration, with the semantics of
      [Caml.( / )]. *)
  val ( / ) : t -> t -> int

  (** [l /. r] is [l]'s duration in seconds divided by [r]'s duration in
      seconds. *)
  val ( /. ) : t -> t -> float
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
