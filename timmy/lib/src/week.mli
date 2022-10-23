(** {1 Type} *)

(** @inline *)
include Type.WEEK

(** @inline *)
include module type of Type_js.Week

(** {1 Construction} *)

(** [make ~year n] is [{ n; year }] if it represents a valid week or a relevant
    error message otherwise. *)
val make : year:int -> int -> (t, string) Result.t

(** {1 Time manipulation} *)

(** [days week] is the sequence of dates in [week] in chronological order. *)
val days : t -> Types_bare.Date.t Base.Sequence.t

(** [day week weekday] is the [weekday] of [week]. *)
val day : t -> Weekday.t -> Types_bare.Date.t

(** {2 Time conversions} *)

(** [to_date week] is the first day (Monday) of [week] *)
val to_date : t -> Date.t

(** [of_date date] is the week that includes [date] *)
val of_date : Date.t -> t

(** {2 Comparison} *)

include Base.Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Base.Comparable.Infix with type t := t

  (** [time + span] is the time point [span] after [time]. *)
  val ( + ) : t -> int -> t
end

include module type of O

(** {1 Scalar conversions} *)

(** {2 Pretty-print} *)

(** [pp f week] prints [week] to [f] in YYYY-NN format, eg. 2021-02. *)
val pp : t Fmt.t

(** {2 String} *)

(** [to_string week] is the YYYY-WW representation of [week], eg. 2022-03. *)
val to_string : t -> string

(** [of_string s] is the week represented by [s] as yielded by [to_string] or a
    relevant error message if it is invalid. *)
val of_string : string -> (t, string) Result.t
