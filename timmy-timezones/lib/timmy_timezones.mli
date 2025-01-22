(** Timezone database integration for Timmy *)

(** List of all the known timezone names (as IANA zone identifiers) *)
val available_zones : string list

(** [of_string name] is the timezone corresponding to the given IANA zone Id, or
    [None] if the zone identifier isn't known. *)
val of_string : string -> Timmy.Timezone.t Base.Option.t
