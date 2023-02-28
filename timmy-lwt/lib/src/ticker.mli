(** Tickers call a function periodically. *)

(** A ticker *)
type t

(** [make ?immediate ?start ~period f] ticks every [period] and calls [f] on
    every tick.

    [start] indicates whether the ticker should start immediately, and if so
    when first tick should happen. Defaults to [Some (Clock.now ())].

    If [immediate], [f] will be called on the first tick (ie. immediately when
    the ticker is started), otherwise it will wait for the second tick. Defaults
    to [true].

    Tickers have no drift: tick are always called a multiple of [period] after
    [start] independently of the run duration of [f] or individual tick
    scheduling approximations. *)
val make :
  ?immediate:bool ->
  ?skip:bool ->
  ?start:Timmy.Time.t option ->
  period:Timmy.Span.t ->
  (Timmy.Time.t -> bool) ->
  t

(** [stop t] prevents any further tick until [t] is started again.

    Noop if [t] was already stopped. *)
val stop : t -> unit

(** [start ?start t] resumes ticking using the same parameters semantics of
    {!make}.

    Noop if [t] was already running. *)
val start : ?start:Timmy.Time.t -> t -> unit
