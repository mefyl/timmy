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
      let obj =
        Schema.Object
          {
            decode = Base.Fn.id;
            encode = Base.Fn.id;
            fields =
              Field
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
                                  title = None;
                                };
                              rest = FieldEnd;
                            };
                      };
                };
          }
      in
      Schema.Map
        {
          decode =
            (* Reject invalid ranges *)
            (fun Hlist.[ hours; minutes; seconds ] ->
              make ~hours ~minutes ~seconds);
          encode =
            (fun { hours; minutes; seconds } -> [ hours; minutes; seconds ]);
          descriptor = obj;
        }
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

  let schema_versioned _ =
    let open Schematic in
    let descriptor =
      Schema.Union
        {
          cases =
            [
              Schema.Case
                {
                  name = "january";
                  raw_name = "January";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "january";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function January -> Some () | _ -> None);
                  decoder = (function () -> January);
                };
              Schema.Case
                {
                  name = "february";
                  raw_name = "February";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "february";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function February -> Some () | _ -> None);
                  decoder = (function () -> February);
                };
              Schema.Case
                {
                  name = "march";
                  raw_name = "March";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "march";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function March -> Some () | _ -> None);
                  decoder = (function () -> March);
                };
              Schema.Case
                {
                  name = "april";
                  raw_name = "April";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "april";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function April -> Some () | _ -> None);
                  decoder = (function () -> April);
                };
              Schema.Case
                {
                  name = "may";
                  raw_name = "May";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "may";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function May -> Some () | _ -> None);
                  decoder = (function () -> May);
                };
              Schema.Case
                {
                  name = "june";
                  raw_name = "June";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "june";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function June -> Some () | _ -> None);
                  decoder = (function () -> June);
                };
              Schema.Case
                {
                  name = "july";
                  raw_name = "July";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "july";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function July -> Some () | _ -> None);
                  decoder = (function () -> July);
                };
              Schema.Case
                {
                  name = "august";
                  raw_name = "August";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "august";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function August -> Some () | _ -> None);
                  decoder = (function () -> August);
                };
              Schema.Case
                {
                  name = "september";
                  raw_name = "September";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "september";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function September -> Some () | _ -> None);
                  decoder = (function () -> September);
                };
              Schema.Case
                {
                  name = "october";
                  raw_name = "October";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "october";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function October -> Some () | _ -> None);
                  decoder = (function () -> October);
                };
              Schema.Case
                {
                  name = "november";
                  raw_name = "November";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "november";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function November -> Some () | _ -> None);
                  decoder = (function () -> November);
                };
              Schema.Case
                {
                  name = "december";
                  raw_name = "December";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "december";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function December -> Some () | _ -> None);
                  decoder = (function () -> December);
                };
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
end

module Time = struct
  (** @inline *)
  include Types_bare.Time

  let schema_versioned _ =
    { Schematic.Schemas.Ptime.schema with id = Some "time" }

  let schema = schema_versioned None
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
      let obj =
        Schema.Object
          {
            decode = Base.Fn.id;
            encode = Base.Fn.id;
            fields =
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
                      title = None;
                    };
                  rest =
                    Field
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
                            title = None;
                          };
                        rest = FieldEnd;
                      };
                };
          }
      in
      Schema.Map
        {
          decode = (fun Hlist.[ n; year ] -> Make.make ~year n);
          encode = (fun { n; year } -> [ n; year ]);
          descriptor = obj;
        }
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

  let schema_versioned _ =
    let open Schematic in
    let descriptor =
      Schema.Union
        {
          cases =
            [
              Schema.Case
                {
                  name = "monday";
                  raw_name = "Monday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "monday";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function Monday -> Some () | _ -> None);
                  decoder = (function () -> Monday);
                };
              Schema.Case
                {
                  name = "tuesday";
                  raw_name = "Tuesday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "tuesday";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function Tuesday -> Some () | _ -> None);
                  decoder = (function () -> Tuesday);
                };
              Schema.Case
                {
                  name = "wednesday";
                  raw_name = "Wednesday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "wednesday";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function Wednesday -> Some () | _ -> None);
                  decoder = (function () -> Wednesday);
                };
              Schema.Case
                {
                  name = "thursday";
                  raw_name = "Thursday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "thursday";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function Thursday -> Some () | _ -> None);
                  decoder = (function () -> Thursday);
                };
              Schema.Case
                {
                  name = "friday";
                  raw_name = "Friday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "friday";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function Friday -> Some () | _ -> None);
                  decoder = (function () -> Friday);
                };
              Schema.Case
                {
                  name = "saturday";
                  raw_name = "Saturday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "saturday";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function Saturday -> Some () | _ -> None);
                  decoder = (function () -> Saturday);
                };
              Schema.Case
                {
                  name = "sunday";
                  raw_name = "Sunday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "sunday";
                      id = None;
                      parametric = None;
                    });
                  encoder = (function Sunday -> Some () | _ -> None);
                  decoder = (function () -> Sunday);
                };
            ];
          key = None;
          polymorphic = false;
        }
    in
    Schema.make ~id:"weekday" descriptor

  let schema = schema_versioned None
  let schema_string = schema
end
