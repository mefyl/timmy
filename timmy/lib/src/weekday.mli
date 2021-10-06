(** @inline *)
include Weekday_intf.V0_10_0

(** {2 Pretty-print} *)

(** [pp f weekday] prints [weekday] to [f] as its english name. *)
val pp : t Fmt.t

(** {2 String} *)

(** [to_string weekday] is the english name of [weekday]. *)
val to_string : t -> string
