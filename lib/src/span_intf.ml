open Base

module type Interface = sig
  type t

  val seconds : int -> t

  val to_days : t -> int

  module O : Comparable.Infix with type t := t

  include Comparable.S with type t := t

  val of_ptime : Ptime.Span.t -> t

  val to_ptime : t -> Ptime.Span.t
end
