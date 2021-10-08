(** @inline *)
include Weekday_intf.V0_10_3

val equal : t -> t -> bool

module O : sig
  val ( = ) : t -> t -> bool

  val ( <> ) : t -> t -> bool
end

include module type of O
