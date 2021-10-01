open Acid

type t = private {
  day : int;
  month : Month.t;
  year : int;
}

include module type of Type

val schema : t Schematic.schema

val make : year:int -> month:int -> day:int -> (t, string) Result.t

val make_overflow :
  ?day_truncate:bool -> year:int -> month:int -> day:int -> unit -> t

val add_days : t -> int -> t

val to_tuple : t -> int * int * int

val to_sexp : t -> Sexp.t

val of_string : string -> (t, string) Result.t

val of_tuple : int * int * int -> (t, string) Result.t

val of_tuple_exn : here:Source_code_position.t -> int * int * int -> t

val of_time : timezone:Timezone.t -> Time.t -> t

val to_time : timezone:Timezone.t -> t -> Time.t

include Base.Comparable.S with type t := t

module O : sig
  include Comparable.Infix with type t := t

  val ( - ) : t -> t -> Span.t
end

include module type of O

val pp : Format.formatter -> t -> unit

val to_string : t -> string

(** [max_month_day year month] is the last day of the given [month] of [year].
    It can be 31, 30, 29 or 28. *)
val max_month_day : int -> int -> int

val weekday : t -> Weekday.t
