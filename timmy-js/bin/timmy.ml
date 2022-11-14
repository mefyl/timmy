module Js = Js_of_ocaml.Js
module Timmy = Timmy_jsoo

let constructor name f =
  let res = Js.Unsafe.callback f in
  let () =
    Js.Unsafe.global##._Object##defineProperty
      res (Js.string "name")
      (object%js
         val value = Js.string name
         val writable = Js._false
      end)
  in
  res

let () =
  let daytime =
    constructor "Daytime" @@ fun hours minutes seconds ->
    let hours = Js.Optdef.get hours (fun () -> 0)
    and minutes = Js.Optdef.get minutes (fun () -> 0)
    and seconds = Js.Optdef.get seconds (fun () -> 0) in
    match Timmy.Daytime.make ~hours ~minutes ~seconds with
    | Result.Ok dt -> Timmy.Daytime.to_js dt
    | Result.Error msg ->
      Js.Js_error.raise_ @@ Js.Js_error.of_error
      @@ new%js Js.error_constr (Js.string msg)
  in
  Js.export_all
    (object%js
       val _Daytime = daytime
    end)
