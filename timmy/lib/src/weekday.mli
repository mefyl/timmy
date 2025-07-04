(** {1 Type} *)

(** {1 Scalar conversions} *)

(** @inline *)
include Type_schema.WEEKDAY

(** {2 Integer} *)

(** [to_int ~base weekday] is the number of days from [base] to the next
    [weekday].

    Base defaults to [Monday].*)
val to_int : ?base:t -> t -> int

(** [of_int n] is [n]-th weekday, starting from [0] for [Monday]. *)
val of_int : int -> t option

(** [add_days weekday n] is the [n]-th weekday after [weekday]. *)
val add_days : t -> int -> t

(** {2 Pretty-print} *)

(** [pp f weekday] prints [weekday] to [f] as its english name. *)
val pp : t Fmt.t

(** {2 String} *)

(** [to_string weekday] is the english name of [weekday]. *)
val to_string : t -> string

(** {2 Comparison} *)

include Base.Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  val ( = ) : t -> t -> bool
  val ( <> ) : t -> t -> bool
end

include module type of O
