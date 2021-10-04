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

(** [to_int ~base weekday] is the number of days from [base] to the next
    [weekday].

    Base defaults to [Monday].*)
val to_int : ?base:t -> t -> int
