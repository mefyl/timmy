module type V0_10_0 = sig
  (** {1 Type} *)

  (** A day of the week. *)
  type t =
    | Monday
    | Tuesday
    | Wednesday
    | Thursday
    | Friday
    | Saturday
    | Sunday

  (** Schema mapping week days to their english name. *)
  val schema_string : t Schematic.Schema.t

  (** [schema] is [schema_int]. *)
  val schema : t Schematic.Schema.t

  (** {1 Scalar conversions} *)

  (** {2 Integer} *)

  (** [to_int ~base weekday] is the number of days from [base] to the next
      [weekday].

      Base defaults to [Monday].*)
  val to_int : ?base:t -> t -> int
end

module type V0_10_3 = sig
  include V0_10_0

  (** {2 Pretty-print} *)

  (** [pp f weekday] prints [weekday] to [f] as its english name. *)
  val pp : t Fmt.t

  (** {2 String} *)

  (** [to_string weekday] is the english name of [weekday]. *)
  val to_string : t -> string
end
