module Schematic = Schematic.Versions.V0_22_3

module type DATE = sig
  (** @inline *)
  include Types_bare.DATE with type t = Types_bare.Date.t

  val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t

  (** [schema] maps dates to [(year, month, day)] triplets. *)
  val schema : t Schematic.Schema.t
end

module Date = struct
  include Types_bare.Date

  let schema_versioned _ =
    Schematic.Schema.make ~id:"date"
    @@ Schematic.Schema.Descriptor.map ~decode:of_tuple ~encode:to_tuple
         Schematic.Schema.Descriptor.date

  let schema = schema_versioned None
end

module type DAYTIME = sig
  include Types_bare.DAYTIME

  val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t

  (** [schema] maps daytimes to hours, minutes, seconds triplets. *)
  val schema : t Schematic.Schema.t
end

module Daytime = struct
  include Types_bare.Daytime

  let schema_versioned _ =
    let open Schematic.Schemas in
    let descriptor =
      let decode Hlist.[ hours; minutes; seconds ] =
        make ~hours ~minutes ~seconds
      and encode { hours; minutes; seconds } =
        Hlist.[ hours; minutes; seconds ]
      in
      let open Schematic.Schema.Descriptor in
      map ~decode ~encode
      @@ object' ~decode:Base.Fn.id ~encode:Base.Fn.id
           [
             field ~maximum:24 ~minimum:0 ~requirement:Required "hours"
               (Outline int_schema);
             field ~maximum:60 ~minimum:0 ~requirement:(Default 0) "minutes"
               (Outline int_schema);
             field ~maximum:60 ~minimum:0 ~requirement:(Default 0) "seconds"
               (Outline int_schema);
           ]
    in
    Schematic.Schema.make ~id:"daytime" descriptor

  let schema = schema_versioned None
end

module type MONTH = sig
  (** @inline *)
  include Types_bare.MONTH

  (** [schema] maps months to their english names. *)
  val schema_string : t Schematic.Schema.t

  (** [schema_int] maps months to integers, 1 being January and 12 December. *)
  val schema_int : t Schematic.Schema.t

  val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t

  (** [schema] is [schema_int]. *)
  val schema : t Schematic.Schema.t
end

module Month = struct
  include Types_bare.Month

  let make_case name encoder decoder =
    let open Schematic in
    Schema.Descriptor.case ~encoder ~decoder name
    @@ Schema.make (String_const name)

  let schema_versioned _ =
    Schematic.Schema.make ~id:"month"
    @@ Schematic.Schema.Descriptor.union
         [
           make_case "january"
             (function January -> Some () | _ -> None)
             (function () -> January);
           make_case "february"
             (function February -> Some () | _ -> None)
             (function () -> February);
           make_case "march"
             (function March -> Some () | _ -> None)
             (function () -> March);
           make_case "april"
             (function April -> Some () | _ -> None)
             (function () -> April);
           make_case "may"
             (function May -> Some () | _ -> None)
             (function () -> May);
           make_case "june"
             (function June -> Some () | _ -> None)
             (function () -> June);
           make_case "july"
             (function July -> Some () | _ -> None)
             (function () -> July);
           make_case "august"
             (function August -> Some () | _ -> None)
             (function () -> August);
           make_case "september"
             (function September -> Some () | _ -> None)
             (function () -> September);
           make_case "october"
             (function October -> Some () | _ -> None)
             (function () -> October);
           make_case "november"
             (function November -> Some () | _ -> None)
             (function () -> November);
           make_case "december"
             (function December -> Some () | _ -> None)
             (function () -> December);
         ]

  let schema = schema_versioned None
  let schema_string = schema

  let schema_int =
    Schematic.Schema.make ~id:"month"
    @@ Map { decode = of_int; encode = to_int; descriptor = Int }
end

module type SPAN = sig
  include Types_bare.SPAN

  val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t

  (** [schema] encode spans a number of seconds. *)
  val schema : t Schematic.Schema.t
end

module Span = struct
  (** @inline *)
  include Types_bare.Span

  let schema_versioned _ =
    { Schematic.Schemas.Ptime.span_schema with id = Some "span" }

  let schema = schema_versioned None
end

module type TIME = sig
  (** @inline *)
  include Types_bare.TIME

  val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t

  (** Time schema. *)
  val schema : t Schematic.Schema.t

  (** An alias to ease schematic-coding times as timestamps. *)
  type timestamp = t

  (** Schema as a POSIX timestamp. *)
  val timestamp_schema : t Schematic.Schema.t

  (** Schema as a POSIX timestamp, versioned. *)
  val timestamp_schema_versioned :
    Schematic.Schema.version -> t Schematic.Schema.t
end

module Time = struct
  (** @inline *)
  include Types_bare.Time

  let schema_versioned _ =
    { Schematic.Schemas.Ptime.schema with id = Some "time" }

  let schema = schema_versioned None

  type timestamp = t

  let timestamp_schema_versioned _ =
    let open Ptime in
    (* FIXME: We would like to rely on int64 to ensure it fits, but ptime does
       not seem to support it. In the meantime such a case seems extremely
       unlikely. *)
    let decode timestamp =
      match of_span @@ Span.of_int_s timestamp with
      | None -> Result.Error (Fmt.str "timestamp out of bounds: %d" timestamp)
      | Some ptime -> Result.Ok ptime
    and encode time =
      match time |> to_span |> Span.to_int_s with
      | Some timestamp -> timestamp
      | None -> Fmt.failwith "timestamp out of bounds"
    in
    Schematic.Schema.make ~id:"timestamp"
    @@ Map { decode; encode; descriptor = Int }

  let timestamp_schema = timestamp_schema_versioned None
end

module type WEEK = sig
  (** @inline *)
  include Types_bare.WEEK with type t = Types_bare.Week.t

  val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t

  (** Week schema. *)
  val schema : t Schematic.Schema.t
end

module Week (Make : sig
  val make : year:int -> int -> (Types_bare.Week.t, string) Result.t
end) =
struct
  include Types_bare.Week

  let schema_versioned _ =
    let open Schematic.Schemas in
    let decode Hlist.[ year; n ] = Make.make ~year n
    and encode { year; n } = Hlist.[ year; n ] in
    let open Schematic.Schema.Descriptor in
    Schematic.Schema.make ~id:"week"
    @@ map ~decode ~encode
    @@ object' ~decode:Base.Fn.id ~encode:Base.Fn.id
         [
           field ~requirement:Required "year" @@ Outline int_schema;
           field ~requirement:Required "n" @@ Outline int_schema;
         ]

  let schema = schema_versioned None
end

module type WEEKDAY = sig
  (** @inline *)
  include Types_bare.WEEKDAY

  (** Schema mapping week days to their english name. *)
  val schema_string : t Schematic.Schema.t

  (** [schema] is [schema_int]. *)
  val schema : t Schematic.Schema.t

  (** [schema_versioned _] is [schema] *)
  val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t
end

module Weekday = struct
  include Types_bare.Weekday

  let schema_versioned _ =
    let open Schematic.Schema.Descriptor in
    let case name encoder decoder =
      case ~decoder ~encoder name @@ Schematic.Schema.make (String_const name)
    in
    Schematic.Schema.make ~id:"weekday"
    @@ union
         [
           case "monday"
             (function Monday -> Some () | _ -> None)
             (function () -> Monday);
           case "tuesday"
             (function Tuesday -> Some () | _ -> None)
             (function () -> Tuesday);
           case "wednesday"
             (function Wednesday -> Some () | _ -> None)
             (function () -> Wednesday);
           case "thursday"
             (function Thursday -> Some () | _ -> None)
             (function () -> Thursday);
           case "friday"
             (function Friday -> Some () | _ -> None)
             (function () -> Friday);
           case "saturday"
             (function Saturday -> Some () | _ -> None)
             (function () -> Saturday);
           case "sunday"
             (function Sunday -> Some () | _ -> None)
             (function () -> Sunday);
         ]

  let schema = schema_versioned None
  let schema_string = schema
end
