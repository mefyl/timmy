open Acid

type t = private {
  hours : int;
  minutes : int;
  seconds : int;
}

include Comparable.S with type t := t

module O : sig
  include Comparable.Infix with type t := t
end

include module type of O

val make : hours:int -> minutes:int -> seconds:int -> (t, string) Result.t

val to_tuple : t -> int * int * int

val to_time : timezone:Timezone.t -> Date.t -> t -> Time.t

val of_tuple : int * int * int -> (t, string) Result.t

val of_tuple_exn : here:Source_code_position.t -> int * int * int -> t

val of_time : timezone:Timezone.t -> Time.t -> t

val pp : Formatter.t -> t -> unit

val with_daytime : timezone:Timezone.t -> t -> Time.t -> Time.t

(** The maximum possible daytime, 23:59:59 *)
val latest : t

val midnight : t

val noon : t
