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
    @@ Map { decode = of_tuple; encode = to_tuple; descriptor = Date }

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
      let decode (* Reject invalid ranges *) Hlist.[ hours; minutes; seconds ] =
        make ~hours ~minutes ~seconds
      and encode { hours; minutes; seconds } = Hlist.[ hours; minutes; seconds ]
      and fields =
        Schematic.Schema.Field
          {
            field =
              {
                description = None;
                examples = [];
                name = "hours";
                maximum = Some 24;
                minimum = Some 0;
                omit = false;
                requirement = Required;
                schema = Outline int_schema;
                since = None;
                title = None;
              };
            rest =
              Field
                {
                  field =
                    {
                      description = None;
                      examples = [];
                      name = "minutes";
                      maximum = Some 60;
                      minimum = Some 0;
                      omit = false;
                      requirement = Default 0;
                      schema = Outline int_schema;
                      since = None;
                      title = None;
                    };
                  rest =
                    Field
                      {
                        field =
                          {
                            description = None;
                            examples = [];
                            name = "seconds";
                            maximum = Some 60;
                            minimum = Some 0;
                            omit = false;
                            requirement = Default 0;
                            schema = Outline int_schema;
                            since = None;
                            title = None;
                          };
                        rest = FieldEnd;
                      };
                };
          }
      in
      let obj =
        Schema.Object { decode = Base.Fn.id; encode = Base.Fn.id; fields }
      in
      Schema.Map { decode; encode; descriptor = obj }
    in
    Schema.make ~id:"daytime" descriptor

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

  let make_case name raw_name encoder decoder =
    let open Schematic in
    Schema.Case
      {
        name;
        raw_name;
        schema = Schema.make (String_const name);
        encoder;
        decoder;
        inline = false;
        since = None;
      }

  let schema_versioned _ =
    let open Schematic in
    let descriptor =
      Schema.Union
        {
          cases =
            [
              make_case "january" "January"
                (function January -> Some () | _ -> None)
                (function () -> January);
              make_case "february" "February"
                (function February -> Some () | _ -> None)
                (function () -> February);
              make_case "march" "March"
                (function March -> Some () | _ -> None)
                (function () -> March);
              make_case "april" "April"
                (function April -> Some () | _ -> None)
                (function () -> April);
              make_case "may" "May"
                (function May -> Some () | _ -> None)
                (function () -> May);
              make_case "june" "June"
                (function June -> Some () | _ -> None)
                (function () -> June);
              make_case "july" "July"
                (function July -> Some () | _ -> None)
                (function () -> July);
              make_case "august" "August"
                (function August -> Some () | _ -> None)
                (function () -> August);
              make_case "september" "September"
                (function September -> Some () | _ -> None)
                (function () -> September);
              make_case "october" "October"
                (function October -> Some () | _ -> None)
                (function () -> October);
              make_case "november" "November"
                (function November -> Some () | _ -> None)
                (function () -> November);
              make_case "december" "December"
                (function December -> Some () | _ -> None)
                (function () -> December);
            ];
          key = None;
          polymorphic = false;
        }
    in
    Schematic.Schema.make ~id:"month" descriptor

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
    let descriptor =
      let decode Hlist.[ year; n ] = Make.make ~year n
      and encode { year; n } = Hlist.[ year; n ]
      and fields =
        Schematic.Schema.Field
          {
            field =
              {
                description = None;
                examples = [];
                name = "year";
                maximum = None;
                minimum = None;
                omit = false;
                requirement = Required;
                schema = Outline int_schema;
                since = None;
                title = None;
              };
            rest =
              Field
                {
                  field =
                    {
                      description = None;
                      examples = [];
                      name = "n";
                      maximum = None;
                      minimum = None;
                      omit = false;
                      requirement = Required;
                      schema = Outline int_schema;
                      since = None;
                      title = None;
                    };
                  rest = FieldEnd;
                };
          }
      in
      let obj =
        Schema.Object { decode = Base.Fn.id; encode = Base.Fn.id; fields }
      in
      Schema.Map { decode; encode; descriptor = obj }
    in
    Schema.make ~id:"week" descriptor

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

  let make_case name raw_name encoder decoder =
    let open Schematic in
    Schema.Case
      {
        name;
        raw_name;
        schema = Schema.make (String_const name);
        encoder;
        decoder;
        inline = false;
        since = None;
      }

  let schema_versioned _ =
    let open Schematic in
    let descriptor =
      Schema.Union
        {
          cases =
            [
              make_case "monday" "Monday"
                (function Monday -> Some () | _ -> None)
                (function () -> Monday);
              make_case "tuesday" "Tuesday"
                (function Tuesday -> Some () | _ -> None)
                (function () -> Tuesday);
              make_case "wednesday" "Wednesday"
                (function Wednesday -> Some () | _ -> None)
                (function () -> Wednesday);
              make_case "thursday" "Thursday"
                (function Thursday -> Some () | _ -> None)
                (function () -> Thursday);
              make_case "friday" "Friday"
                (function Friday -> Some () | _ -> None)
                (function () -> Friday);
              make_case "saturday" "Saturday"
                (function Saturday -> Some () | _ -> None)
                (function () -> Saturday);
              make_case "sunday" "Sunday"
                (function Sunday -> Some () | _ -> None)
                (function () -> Sunday);
            ];
          key = None;
          polymorphic = false;
        }
    in
    Schema.make ~id:"weekday" descriptor

  let schema = schema_versioned None
  let schema_string = schema
end
