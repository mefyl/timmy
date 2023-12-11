(** Tickers call a function periodically. *)

(** A ticker *)
type t

(** [make ?immediate ?start ~period f] ticks every [period] and calls [f] on
    every tick.

    [start] determines whether the ticker should start immediately, and is
    equivalent to immediately calling [start ~start t]. Defaults to
    [Some (Clock.now ())].

    [skip] determines whether to drop duplicate ticks if multiple are due upon
    scheduling time, which can easily happen if the host is put to sleep for
    long enough. In such case, only the most recent tick is run. Defaults to
    [true].

    If [immediate], [f] will be called on the first tick (ie. immediately when
    the ticker is started), otherwise it will wait for the second tick. Defaults
    to [true].

    Tickers have no drift: tick are always called a multiple of [period] after
    [start] independently of the run duration of [f] or individual ticks
    scheduling approximations. *)
val make :
  ?immediate:bool ->
  ?skip:bool ->
  ?start:Timmy.Time.t option ->
  period:Timmy.Span.t ->
  (Timmy.Time.t -> bool) ->
  t

(** [pause t] stops [t]'s tick from triggering.

    When restarted without a start time, untriggered ticks are considered for
    scheduling:

    - If no tick was overlooked during the pause, the behavior is the same as if
      no pause happened.
    - If one ore more ticks were overlooked and [skip t], the latest is run
      immediately and normal tick scheduling resumse.
    - If one ore more ticks were overlooked and [not (skip t)], they are all run
      immediately in order and normal tick scheduling resumes.

    Noop if [t] was already stopped or paused. *)
val pause : t -> unit

(** [stop t] stops triggering [t]'s ticks.

    Noop if [t] was already stopped. *)
val stop : t -> unit

(** [start ?start t] resumes ticking using the same parameters semantics of
    {!make}.

    Noop if [t] was already running. *)
val start : ?start:Timmy.Time.t -> t -> unit

(** [finalise t] unrevokably stops [t].

    This must be called to disposes of all of [t]'s ressources. *)
val finalise : t -> unit

(** [skip t] is whether [t] was created with [skip]. *)
val skip : t -> bool
