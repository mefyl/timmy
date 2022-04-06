include module type of Timmy.Timezone

(** [native] is a system specific implementation that relies on the underlying
    system to adjust for evolving timezones. *)
val native : t
