module Js = Js_of_ocaml.Js

module Date = struct
  type js = Js.date Js.t
end

module Time = struct
  type js = Js.date Js.t
end

module Week = struct
  type js =
    < n : Js.number Js.readonly_prop ; year : Js.number Js.readonly_prop > Js.t
end
