open Acid

type t

val days : int -> t

val seconds : int -> t

val to_days : t -> int

val to_seconds : t -> int

module O : sig
  include Comparable.Infix with type t := t

  val ( ~- ) : t -> t
end

include module type of O

include Comparable.S with type t := t

val of_ptime : Ptime.Span.t -> t

val to_ptime : t -> Ptime.Span.t
