open Base

type state =
  | Stopped
  | Running of { next_tick : Timmy.Time.t }
  | Paused of { next_tick_at_pause : Timmy.Time.t }

and command =
  | Finalize of { from_gc : bool }
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

let _run ({ command; f; period; skip; _ } as ticker) =
  let finalized, finalize = Lwt.wait () in
  let () =
    Stdlib.Gc.finalise_last
      (fun () -> Lwt.wakeup finalize (Finalize { from_gc = true }))
      ticker
  in
  let ( >>= ) = Lwt.bind
  and ( >>| ) v f = Lwt.map f v in
  let finalize from_gc =
    let () =
      if from_gc then
        Logs.err (fun m ->
            m "@[<2>%a@]" Fmt.words
              "Timmy_lwt.Ticker.t was not finalized. While resources are freed \
               by this fallback upon garbage collection, it is not advised to \
               rely upon it.")
    in
    Lwt.return ()
  in
  let rec tick state =
    let command = Lwt.choose [ Lwt_mvar.take command; finalized ] in
    tick_with_command command state
  and tick_with_command command state =
    match state with
    | Paused { next_tick_at_pause } -> (
      command >>= function
      | Finalize { from_gc } -> finalize from_gc
      | Stop -> tick Stopped
      | Pause -> tick state
      | Start (Some next_tick) -> tick (Running { next_tick })
      | Start None -> tick (Running { next_tick = next_tick_at_pause }))
    | Stopped -> (
      command >>= function
      | Finalize { from_gc } -> finalize from_gc
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
      | Some (Finalize { from_gc }) -> finalize from_gc
      | Some (Start None) -> tick state
      | Some (Start (Some next_tick)) -> tick (Running { next_tick })
      | Some Pause -> tick (Paused { next_tick_at_pause = next_tick })
      | Some Stop -> tick Stopped
      | None ->
        let keep_going, next_tick =
          let tick_time =
            let skipped =
              Timmy.Span.(Timmy.Time.(Clock.now () - next_tick) / period)
            in
            if skip && Base.Int.(skipped > 0) then
              Timmy.Time.(next_tick + Timmy.Span.(period * skipped))
            else next_tick
          in
          (f tick_time, Timmy.Time.(tick_time + period))
        in
        if keep_going then tick_with_command command (Running { next_tick })
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

let finalize ticker =
  Lwt.async @@ fun () ->
  Lwt_mvar.put ticker.command (Finalize { from_gc = false })

let start ?start ticker =
  Lwt.async @@ fun () ->
  match start with
  | None -> Lwt_mvar.put ticker.command (Start None)
  | Some start_time ->
    Lwt_mvar.put ticker.command
      (start_state ~immediate:ticker.immediate ~period:ticker.period start_time)

let stop ticker = Lwt.async @@ fun () -> Lwt_mvar.put ticker.command Stop
let pause ticker = Lwt.async @@ fun () -> Lwt_mvar.put ticker.command Pause
let skip { skip; _ } = skip
