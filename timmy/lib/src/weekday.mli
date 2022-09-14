(** {1 Type} *)

(** {1 Scalar conversions} *)

(** @inline *)
include Type.WEEKDAY

include module type of Type_js.Weekday

(** {2 Integer} *)

(** [to_int ~base weekday] is the number of days from [base] to the next
    [weekday].

    Base defaults to [Monday].*)
val to_int : ?base:t -> t -> int

(** {2 Pretty-print} *)

(** [pp f weekday] prints [weekday] to [f] as its english name. *)
val pp : t Fmt.t

(** {2 String} *)

(** [to_string weekday] is the english name of [weekday]. *)
val to_string : t -> string

val equal : t -> t -> bool
val compare : t -> t -> int

module O : sig
  val ( = ) : t -> t -> bool
  val ( <> ) : t -> t -> bool
end

include module type of O
