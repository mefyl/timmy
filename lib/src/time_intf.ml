open Base

module type Interface = sig
  type t

  type js = Js_of_ocaml.Js.date Js_of_ocaml.Js.t

  (* val of_js : js -> (t, [> Schematic_jsoo.Jsoo.decode_error ]) Result.t
   *
   * val of_js_exn : js -> t *)

  val schema : t Schematic.schema

  val of_ptime : Ptime.t -> t

  val to_ptime : t -> Ptime.t

  val compare : t -> t -> int

  module O : sig
    include Comparable.Infix with type t := t

    val ( - ) : t -> t -> Span.t
  end

  include module type of O

  val pp : Formatter.t -> t -> unit

  val to_string : t -> string
end
