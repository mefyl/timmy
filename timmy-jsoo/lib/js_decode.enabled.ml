module Js = Js_of_ocaml.Js

module Daytime = struct
  let prototype =
    let res =
      object%js (self)
        method valueOf =
          let self = Js.Unsafe.coerce self in
          (self##.hours * 60 * 60)
          + (Js.Optdef.get self##.minutes (fun () -> 0) * 60)
          + Js.Optdef.get self##.seconds (fun () -> 0)
      end
    in
    let () =
      Js.Unsafe.global##._Object##defineProperty
        res (Js.string "hours")
        (object%js
           val value = 0
           val writable = false
        end)
    and () =
      Js.Unsafe.global##._Object##defineProperty
        res (Js.string "minutes")
        (object%js
           method get = 0
        end)
    and () =
      Js.Unsafe.global##._Object##defineProperty
        res (Js.string "seconds")
        (object%js
           method get = 0
        end)
    in
    res

  let to_js, of_js, of_js_exn =
    Schematic_jsoo.Jsoo.helpers_typed
      (module struct
        type js = Js_of_ocaml.Js.Unsafe.any

        include Timmy.Daytime
      end)
      "Timmy.Daytime.t" Timmy.Daytime.schema

  let to_js e =
    let res = to_js e in
    let () = Js.Unsafe.global##._Object##setPrototypeOf res prototype in
    Js.Unsafe.global##._Object##freeze res
end

module Week = struct
  let to_js, of_js, of_js_exn =
    Schematic_jsoo.Jsoo.helpers_typed
      (module struct
        type js = Js_of_ocaml.Js.Unsafe.any

        include Timmy.Week
      end)
      "Timmy.Week.t" Timmy.Week.schema
end
