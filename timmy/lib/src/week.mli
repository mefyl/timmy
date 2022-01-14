open Acid

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

(** {2 Time conversions} *)

(** [to_date week] is the first day (Monday) of [week] *)
val to_date : t -> Date.t

(** [of_date date] is the week than includes [date] *)
val of_date : Date.t -> t

(** {2 Comparison} *)

include Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Comparable.Infix with type t := t

  (** [time + span] is the time point [span] after [time]. *)
  val ( + ) : t -> int -> t
end

include module type of O

(** {1 Scalar conversions} *)

(** {2 Pretty-print} *)

(** [pp f week] prints [week] to [f] in YYYY-NN format, eg. 2021-02. *)
val pp : t Fmt.t
