open Acid

module type V0_10_3 = sig
  (** {1 Type} *)

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

  (** Schema mapping months to their english names. *)
  val schema_string : t Schematic.Schema.t

  (** Schema mapping months to integers, 1 being January and 12 December. *)
  val schema_int : t Schematic.Schema.t

  (** [schema] is [schema_int]. *)
  val schema : t Schematic.Schema.t

  (** {1 Time manipulation} *)

  (** {1 Scalar conversions} *)

  (** {2 Integer} *)

  (** [to_int month] is 1-based index of [month] in the year, ie. 1 is January
      and 12 is December. *)
  val to_int : t -> int

  (** [of_int n] is the [t] corresponding to the [n]th month of the year, 1
      being January and 12 December. *)
  val of_int : int -> (t, string) Result.t

  (** {2 Pretty-print} *)

  (** [pp f month] pretty-prints [month] to [f] as its english name. *)
  val pp : t Fmt.t

  (** {2 String} *)

  (** [to_string month] is the english name of [month]. *)
  val to_string : t -> string
end
