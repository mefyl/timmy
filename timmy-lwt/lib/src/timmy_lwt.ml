module Ticker = Ticker

let sleep seconds =
  Timmy_lwt_platform.sleep
  @@ Ptime.Span.to_float_s
  @@ Timmy.Span.to_ptime seconds

let yield = Timmy_lwt_platform.yield
