let virtual_engine actual : Lwt_engine.t =
  let in_, out = Unix.pipe () in
  let () =
    let cb _now = actual#fake_io out in
    Clock_virtual.set_callback cb
  in
  let res =
    object (self)
      inherit Lwt_engine.abstract

      method register_writable fd f =
        let event = actual#on_writable fd (fun _ -> f ()) in
        lazy (Lwt_engine.stop_event event)

      method register_readable fd f =
        let event = actual#on_readable fd (fun _ -> f ()) in
        lazy (Lwt_engine.stop_event event)

      method iter block = actual#iter block

      method cleanup =
        Unix.close in_;
        Unix.close out;
        actual#destroy

      method register_timer delay repeat f =
        assert (not repeat);
        let deadline =
          match Ptime.Span.of_float_s delay with
          | Some delay ->
            Timmy.Time.(Clock_virtual.get () + Timmy.Span.of_ptime delay)
          | None -> Fmt.failwith "invalid delay: %f" delay
        in
        if Timmy.Time.(deadline <= Clock_virtual.get ()) then
          let () = f () in
          lazy ()
        else
          let rec stop =
            lazy
              (self#register_readable out (fun () ->
                   if Timmy.Time.(deadline <= Clock_virtual.get ()) then
                     let () = Lazy.force (Lazy.force stop) in
                     f ()))
          in
          Lazy.force stop
    end
  in
  (res :> Lwt_engine.t)

let install () = Lwt_engine.set (virtual_engine @@ Lwt_engine.get ())
