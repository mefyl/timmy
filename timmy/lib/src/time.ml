open Base

module T = struct
  include Type_schema.Time

  let compare = Ptime.compare
  let sexp_of_t t = Sexp.Atom (Ptime.to_rfc3339 t)
end

module Infix = struct
  include Comparable.Make (T)

  let ( + ) t span =
    Option.value_exn ~here:[%here] (Ptime.add_span t @@ Span.to_ptime span)

  let ( - ) l r = Ptime.diff l r |> Span.of_ptime
end

include T
include Infix

let of_ptime t = t

let of_rfc3339 s =
  match Ptime.of_rfc3339 ~strict:true s with
  | Result.Ok (time, _, _) -> Result.Ok time
  | Result.Error (`RFC3339 (_, e)) ->
    Result.fail Fmt.(str "invalid date: %a" Ptime.pp_rfc3339_error e)

let of_string = of_rfc3339
let to_ptime t = t
let pp = Ptime.pp

let to_rfc3339 ?timezone t =
  let tz_offset_s =
    let f tz = Timezone.gmt_offset_seconds_at_time tz t in
    Option.map timezone ~f
  in
  Ptime.to_rfc3339 ?tz_offset_s t

let to_string = to_rfc3339
let epoch = Ptime.epoch

module O = Infix
