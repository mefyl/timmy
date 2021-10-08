open Acid

(** @inline *)
include Month_intf.V0_10_3

(** {2 Comparison} *)

include Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : Comparable.Infix with type t := t

include module type of O
