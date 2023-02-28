(* There is room for additional features like stopping, pausing, ... *)

type t = {
  f : Timmy.Time.t -> bool;
  immediate : bool;
  period : Timmy.Span.t;
  mutable running : bool;
  skip : bool;
  stop : unit Lwt_mvar.t;
}

let start ?start ({ f; immediate; period; skip; stop; _ } as t) =
  let ( let* ) = Lwt.bind
  and ( >>| ) v f = Lwt.map f v in
  let start = match start with None -> Clock.now () | Some start -> start in
  if not t.running then
    let () = t.running <- true in
    let rec tick immediate time =
      let now = Clock.now () in
      let* run, time =
        let delay = Timmy.Time.(time - now) in
        Lwt.choose
          [
            ( Timmy_lwt_platform.sleep
                (delay |> Timmy.Span.to_ptime |> Ptime.Span.to_float_s)
            >>| fun () -> (true, time) );
            (Lwt_mvar.take stop >>| fun () -> (false, time));
          ]
      in
      if run then
        let time =
          let skipped =
            Timmy.Span.(Timmy.Time.(Clock.now () - time) / period)
          in
          if skip && Base.Int.(skipped > 0) then
            Timmy.Time.(time + Timmy.Span.(period * skipped))
          else time
        in
        let next = if immediate then f time else true in
        if next then tick true Timmy.Time.(time + period) else Lwt.return ()
      else Lwt.return ()
    in
    Lwt.async (fun () -> tick immediate start)

let stop t =
  if t.running then
    let () = t.running <- false in
    Lwt.async (fun () -> Lwt_mvar.put t.stop ())

let make ?(immediate = true) ?(skip = true) ?start:start_time ~period f =
  let res =
    {
      f;
      immediate;
      period;
      running = false;
      skip;
      stop = Lwt_mvar.create_empty ();
    }
  in
  let () =
    match start_time with
    | None -> start res
    | Some (Some start_time) -> start ~start:start_time res
    | Some None -> ()
  in
  res
