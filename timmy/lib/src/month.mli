(** A month. *)
type t =
  | January
  | February
  | March
  | April
  | May
  | June
  | July
  | August
  | September
  | October
  | November
  | December

(** Schema mapping to month names as strings. *)
val schema_string : t Schematic.Schema.t

(** Schema mapping to integers, 1 being January and 12 December. *)
val schema_int : t Schematic.Schema.t

(** [schema] is [schema_int]. *)
val schema : t Schematic.Schema.t

(** [to_int month] is 1-based index of [month] in the year, ie. 1 is January and
    12 is December. *)
val to_int : t -> int

(** [of_int n] is the [t] corresponding to the [n]th month of the year, 1 being
    January and 12 December. *)
val of_int : int -> (t, string) Result.t

(** [to_string month] is the english name of [month]. *)
val to_string : t -> string

(** [pp] pretty prints months as their english name. *)
val pp : t Fmt.t
