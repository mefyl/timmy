let () = Timmy_lwt_virtual.install ()
let ( let+ ) v f = Lwt.map f v

let sleep _ () =
  let beacon = ref false in
  let () =
    Lwt.async (fun () ->
        let+ () = Lwt_unix.sleep 1.0 in
        beacon := true)
  in
  Alcotest.(check ~here:[%here] bool) "before sleeping" false !beacon;
  Clock_virtual.forward @@ Timmy.Span.seconds 2;
  Alcotest.(check ~here:[%here] bool) "after sleeping" true !beacon;
  Lwt.return ()

let () =
  Lwt_main.run
  @@ Alcotest_lwt.run "timmy-lwt.virtual"
       [ ("engine", [ Alcotest_lwt.test_case "sleep" `Quick sleep ]) ]
