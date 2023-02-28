open Base

let () = Timmy_lwt_virtual.install ()

let skip _ () =
  let ticks = ref []
  and ticks_skipped = ref [] in
  let ticker ticks skip =
    Timmy_lwt.Ticker.make ~period:(Timmy.Span.minutes 1) ~skip (fun time ->
        let () = ticks := time :: !ticks in
        true)
  and check ~here exp_ticks exp_ticks_skipped =
    let exp exp =
      List.map exp ~f:(fun i -> Timmy.Time.(epoch + Timmy.Span.minutes i))
    in
    Alcotest.(check ~here (list @@ testable Timmy.Time.pp Timmy.Time.equal))
      "ticks" (exp exp_ticks) !ticks;
    Alcotest.(check ~here (list @@ testable Timmy.Time.pp Timmy.Time.equal))
      "skipped ticks" (exp exp_ticks_skipped) !ticks_skipped
  in
  let _ticker = ticker ticks false
  and _skip_ticker = ticker ticks_skipped true in
  let () = Clock_virtual.forward @@ Timmy.Span.seconds 30 in
  let () = check ~here:[%here] [ 0 ] [ 0 ] in
  let () = Clock_virtual.forward @@ Timmy.Span.minutes 1 in
  let () = check ~here:[%here] [ 1; 0 ] [ 1; 0 ] in
  let () = Clock_virtual.forward @@ Timmy.Span.minutes 5 in
  let () = check ~here:[%here] [ 6; 5; 4; 3; 2; 1; 0 ] [ 6; 1; 0 ] in
  Lwt.return ()

let () =
  Lwt_main.run
  @@ Alcotest_lwt.run "Picker"
       [ ("run", [ Alcotest_lwt.test_case "skip" `Quick skip ]) ]
