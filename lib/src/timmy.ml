module Date : Date.Interface with type t = Date.t = Date

module Span : Span.Interface with type t = Span.t = Span

module Time : Time.Interface with type t = Time.t = Time

module Timezone = Timezone

type date = Date.t [@@deriving schema]

type date_js = Js_of_ocaml.Js.date Js_of_ocaml.Js.t
