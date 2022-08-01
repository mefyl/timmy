module Daytime = struct
  let to_js, of_js, of_js_exn =
    Schematic_jsoo.Jsoo.helpers_typed
      (module Timmy.Daytime)
      "Timmy.Daytime.t" Timmy.Daytime.schema
end

module Week = struct
  let to_js, of_js, of_js_exn =
    Schematic_jsoo.Jsoo.helpers_typed
      (module Timmy.Week)
      "Timmy.Week.t" Timmy.Week.schema
end
