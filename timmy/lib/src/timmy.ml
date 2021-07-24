module Date : Date.Interface with type t = Date.t = Date

module Daytime = Daytime

module Span : Span.Interface with type t = Span.t = Span

module Time : Time.Interface with type t = Time.t = Time

module Timezone = Timezone
module Weekday = Weekday

type date = Date.t [@@deriving schema]
