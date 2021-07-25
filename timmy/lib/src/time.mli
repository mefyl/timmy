open Base

type t

include module type of Type

val schema : t Schematic.schema

val of_ptime : Ptime.t -> t

val of_rfc3339 : string -> (t, string) Result.t

val of_string : string -> (t, string) Result.t

val to_ptime : t -> Ptime.t

include Base.Comparable.S with type t := t

module O : sig
  include Comparable.Infix with type t := t

  val ( + ) : t -> Span.t -> t

  val ( - ) : t -> t -> Span.t
end

include module type of O

val pp : Formatter.t -> t -> unit

val to_string : t -> string

val to_rfc3339 : ?timezone:Timezone.t -> t -> string

val epoch : t
