open Acid

(** @inline *)
include Date_intf.V0_10_4

(** {2 Integer} *)

(** [to_int date] is the {{:https://en.wikipedia.org/wiki/Julian_day} Julian
    day} of [date]. *)
val to_int : t -> int

(** [of_int jd] is the date of the {{:https://en.wikipedia.org/wiki/Julian_day}
    Julian day} [jd]. *)
val of_int : int -> t
