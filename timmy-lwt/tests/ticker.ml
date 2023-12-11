open Base

let () = Timmy_lwt_virtual.install ()
let () = Logs.set_reporter @@ Logs_fmt.reporter ()

let immediate_on_start _ () =
  let count = ref 0 in
  let ticker =
    Timmy_lwt.Ticker.make ~immediate:false ~period:(Timmy.Span.minutes 1)
      (fun _ ->
        let () = count := !count + 1 in
        true)
  in
  let () =
    Alcotest.(check ~here:[%here] int)
      "ticker did not tick immediately" 0 !count
  in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 90 in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 60 in
  let () =
    Alcotest.(check ~here:[%here] int) "ticker ticked twice afterwards" 2 !count
  in
  let () = Timmy_lwt.Ticker.finalise ticker in
  Lwt.return ()

let skip _ () =
  let test_start_time = Clock.now () in
  let ticks = ref []
  and ticks_skipped = ref [] in
  let ticker ticks skip =
    Timmy_lwt.Ticker.make ~period:(Timmy.Span.minutes 1) ~skip (fun time ->
        let () = ticks := time :: !ticks in
        true)
  and check ~here exp_ticks exp_ticks_skipped =
    let exp exp =
      List.map exp ~f:(fun i ->
          Timmy.Time.(test_start_time + Timmy.Span.minutes i))
    in
    Alcotest.(check ~here (list @@ testable Timmy.Time.pp Timmy.Time.equal))
      "ticks" (exp exp_ticks) !ticks;
    Alcotest.(check ~here (list @@ testable Timmy.Time.pp Timmy.Time.equal))
      "skipped ticks" (exp exp_ticks_skipped) !ticks_skipped
  in
  let ticker = ticker ticks false
  and skip_ticker = ticker ticks_skipped true in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 30 in
  let () = check ~here:[%here] [ 0 ] [ 0 ] in
  let () = Clock_virtual.forward @@ Timmy.Span.minutes 1 in
  let () = check ~here:[%here] [ 1; 0 ] [ 1; 0 ] in
  let () = Clock_virtual.forward @@ Timmy.Span.minutes 5 in
  let () = check ~here:[%here] [ 6; 5; 4; 3; 2; 1; 0 ] [ 6; 1; 0 ] in
  let () = Timmy_lwt.Ticker.finalise ticker
  and () = Timmy_lwt.Ticker.finalise skip_ticker in
  Lwt.return ()

let stop_resume _ () =
  let count = ref 0 in
  let ticker =
    Timmy_lwt.Ticker.make ~period:(Timmy.Span.minutes 1) (fun _ ->
        let () = count := !count + 1 in
        true)
  in
  let () = Alcotest.(check ~here:[%here] int) "count" 1 !count in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 90 in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 60 in
  let () = Alcotest.(check ~here:[%here] int) "count" 3 !count in
  let () = Timmy_lwt.Ticker.stop ticker in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 60 in
  let () = Alcotest.(check ~here:[%here] int) "count" 3 !count in
  let () = Timmy_lwt.Ticker.start ticker in
  let () = Alcotest.(check ~here:[%here] int) "count" 4 !count in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 60 in
  let () = Alcotest.(check ~here:[%here] int) "count" 5 !count in
  let () = Timmy_lwt.Ticker.finalise ticker in
  Lwt.return ()

let forgotten_finalise _ () =
  let errors = Logs.err_count () in
  let () =
    let _ticker =
      Timmy_lwt.Ticker.make ~period:(Timmy.Span.minutes 1) (fun _ -> true)
    in
    ()
  in
  let () = Stdlib.Gc.full_major () in
  Lwt.return
  @@ Alcotest.(check ~here:[%here] int) "an error log was emitted" (errors + 1)
  @@ Logs.err_count ()

let () =
  Lwt_main.run
  @@ Alcotest_lwt.(
       run "Picker"
         [
           ( "run",
             [
               test_case "not immediate on start" `Quick immediate_on_start;
               test_case "skip" `Quick skip;
               test_case "stop / resume" `Quick stop_resume;
               test_case "forgotten finalise" `Quick forgotten_finalise;
             ] );
         ])
