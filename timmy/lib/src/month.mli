open Acid

(** {1 Type} *)

(** @inline *)
include Type.MONTH with type t = Types_bare.Month.t

(** {1 Time manipulation} *)

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
module O : Comparable.Infix with type t := t

include module type of O
