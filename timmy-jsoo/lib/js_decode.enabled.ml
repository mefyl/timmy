module Daytime = struct
  let prototype =
    let open Js_of_ocaml in
    object%js (self)
      val hours = 0
      val minutes = Js.undefined
      val seconds = Js.undefined

      method valueOf =
        (self##.hours * 60 * 60)
        + (Js.Optdef.get self##.minutes (fun () -> 0) * 60)
        + Js.Optdef.get self##.seconds (fun () -> 0)
    end

  let to_js, of_js, of_js_exn =
    Schematic_jsoo.Jsoo.helpers_typed
      (module Timmy.Daytime)
      "Timmy.Daytime.t" Timmy.Daytime.schema

  let to_js e =
    let res = to_js e in
    let () =
      Js_of_ocaml.Js.Unsafe.global##._Object##setPrototypeOf res prototype
    in
    res
end

module Week = struct
  let to_js, of_js, of_js_exn =
    Schematic_jsoo.Jsoo.helpers_typed
      (module Timmy.Week)
      "Timmy.Week.t" Timmy.Week.schema
end
