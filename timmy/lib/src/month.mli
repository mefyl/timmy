open Acid

(** {1 Type} *)

(** @inline *)
include Type.MONTH with type t = Types_bare.Month.t

(** {1 Time manipulation} *)

(** [add_months month n] is the month occuring [n] months after [month]. *)
val add_months : t -> int -> t

(** [days ~year month] is the sequence of days in [month] of year [year] in
    chronological order. *)
val days : year:int -> t -> Types_bare.Date.t Base.Sequence.t

(** [to_date ~year month] is the first day of month [month] in year [year] *)
val to_date : year:int -> t -> Types_bare.Date.t

(** {1 Scalar conversions} *)

(** {2 Integer} *)

(** [to_int month] is 1-based index of [month] in the year, ie. 1 is January and
    12 is December. *)
val to_int : t -> int

(** [of_int n] is the [t] corresponding to the [n]th month of the year, 1 being
    January and 12 December. *)
val of_int : int -> (t, string) Result.t

(** {2 Pretty-print} *)

(** [pp f month] pretty-prints [month] to [f] as its english name. *)
val pp : t Fmt.t

(** {2 String} *)

(** [to_string month] is the english name of [month]. *)
val to_string : t -> string

(** {2 Comparison} *)

include Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Comparable.Infix with type t := t

  (** [month + n] is [add_months month n] *)
  val ( + ) : t -> int -> t
end

include module type of O
