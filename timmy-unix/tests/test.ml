let () = Logs.set_reporter @@ Logs_fmt.reporter ()
let () = Alcotest.(run "Timmy-unix" Clock_tests.v)
