open Base

type state =
  | Stopped
  | Running of { next_tick : Timmy.Time.t }
  | Paused of { next_tick_at_pause : Timmy.Time.t }

and command =
  | Finalise
  | Pause
  | Start of Timmy.Time.t option
  | Stop

type t = {
  command : command Lwt_mvar.t;
  f : Timmy.Time.t -> bool;
  immediate : bool;
  period : Timmy.Span.t;
  skip : bool;
}

let _run t =
  let ( >>= ) = Lwt.bind
  and ( >>| ) v f = Lwt.map f v in
  let rec tick state =
    let command = Lwt_mvar.take t.command in
    tick_with_command command state
  and tick_with_command command state =
    match state with
    | Paused { next_tick_at_pause } -> (
      command >>= function
      | Finalise -> Lwt.return ()
      | Stop -> tick Stopped
      | Pause -> tick state
      | Start (Some next_tick) -> tick (Running { next_tick })
      | Start None -> tick (Running { next_tick = next_tick_at_pause }))
    | Stopped -> (
      command >>= function
      | Finalise -> Lwt.return ()
      | Stop | Pause -> tick Stopped
      | Start next_tick ->
        let next_tick =
          match next_tick with Some time -> time | None -> Clock.now ()
        in
        tick (Running { next_tick }))
    | Running { next_tick } -> (
      let now = Clock.now () in
      let wait =
        let delay = Timmy.Time.(next_tick - now) in
        Lwt.choose
          [
            ( Timmy_lwt_platform.sleep
                (delay |> Timmy.Span.to_ptime |> Ptime.Span.to_float_s)
            >>| fun () -> None );
            command >>| Option.return;
          ]
      in
      wait >>= function
      | Some Finalise -> Lwt.return ()
      | Some (Start None) -> tick state
      | Some (Start (Some next_tick)) -> tick (Running { next_tick })
      | Some Pause -> tick (Paused { next_tick_at_pause = next_tick })
      | Some Stop -> tick Stopped
      | None ->
        let tick_time =
          let skipped =
            Timmy.Span.(Timmy.Time.(Clock.now () - next_tick) / t.period)
          in
          if t.skip && Base.Int.(skipped > 0) then
            Timmy.Time.(next_tick + Timmy.Span.(t.period * skipped))
          else next_tick
        in
        let keep_going = t.f tick_time in
        if keep_going then
          tick_with_command command
            (Running { next_tick = Timmy.Time.(tick_time + t.period) })
        else tick_with_command command Stopped)
  in
  Lwt.async (fun () -> tick Stopped)

let start_state ~immediate ~period start_time =
  let start_time =
    if immediate then start_time else Timmy.Time.(start_time + period)
  in
  Start (Some start_time)

let make ?(immediate = true) ?(skip = true) ?start:start_time ~period f =
  let ticker =
    let initial_command =
      match start_time with
      | None -> Lwt_mvar.create (start_state ~immediate ~period @@ Clock.now ())
      | Some (Some start_time) ->
        Lwt_mvar.create (start_state ~immediate ~period start_time)
      | Some None -> Lwt_mvar.create_empty ()
    in
    { command = initial_command; f; immediate; period; skip }
  in
  let () = _run ticker in
  ticker

let finalise t = Lwt.async @@ fun () -> Lwt_mvar.put t.command Finalise

let start ?start t =
  Lwt.async @@ fun () ->
  match start with
  | None -> Lwt_mvar.put t.command (Start None)
  | Some start_time ->
    Lwt_mvar.put t.command
      (start_state ~immediate:t.immediate ~period:t.period start_time)

let stop t = Lwt.async @@ fun () -> Lwt_mvar.put t.command Stop
let pause t = Lwt.async @@ fun () -> Lwt_mvar.put t.command Pause
let skip { skip; _ } = skip
