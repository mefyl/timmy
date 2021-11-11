module type DATE = sig
  (** @inline *)
  include Types_bare.DATE

  (** [schema] maps dates to [(year, month, day)] triplets. *)
  val schema : t Schematic.schema
end

module Date = struct
  include Types_bare.Date

  let schema =
    Schematic.Schema.(make ~id:"date" (Map (of_tuple, to_tuple, Date)))
end

module type MONTH = sig
  (** @inline *)
  include Types_bare.MONTH

  (** [schema] maps months to their english names. *)
  val schema_string : t Schematic.Schema.t

  (** [schema_int] maps months to integers, 1 being January and 12 December. *)
  val schema_int : t Schematic.Schema.t

  (** [schema] is [schema_int]. *)
  val schema : t Schematic.Schema.t
end

module Month = struct
  include Types_bare.Month

  let schema =
    let open Schematic in
    let descriptor =
      Schema.Union
        {
          cases =
            [
              Schema.Case
                {
                  name = "january";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "january";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | January -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> January);
                };
              Schema.Case
                {
                  name = "february";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "february";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | February -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> February);
                };
              Schema.Case
                {
                  name = "march";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "march";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | March -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> March);
                };
              Schema.Case
                {
                  name = "april";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "april";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | April -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> April);
                };
              Schema.Case
                {
                  name = "may";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "may";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | May -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> May);
                };
              Schema.Case
                {
                  name = "june";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "june";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | June -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> June);
                };
              Schema.Case
                {
                  name = "july";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "july";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | July -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> July);
                };
              Schema.Case
                {
                  name = "august";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "august";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | August -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> August);
                };
              Schema.Case
                {
                  name = "september";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "september";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | September -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> September);
                };
              Schema.Case
                {
                  name = "october";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "october";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | October -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> October);
                };
              Schema.Case
                {
                  name = "november";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "november";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | November -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> November);
                };
              Schema.Case
                {
                  name = "december";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "december";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | December -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> December);
                };
            ];
          key = None;
        }
    and id = "type.js" in
    let open Schematic.Schema in
    { descriptor; id = Some id; parametric = None }

  let schema_string = schema

  let schema_int =
    let open Schematic.Schema in
    {
      descriptor = Map (of_int, to_int, Int);
      id = Some "month";
      parametric = None;
    }
end

module Time = struct
  (** @inline *)
  include Types_bare.Time

  (** Time schema. *)
  let schema = { Schematic.Schema.Schemas.Ptime.schema with id = Some "time" }
end

module type TIME = module type of Time

module Weekday = struct
  include Types_bare.Weekday

  let schema =
    let open Schematic in
    let descriptor =
      Schema.Union
        {
          cases =
            [
              Schema.Case
                {
                  name = "monday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "monday";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | Monday -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> Monday);
                };
              Schema.Case
                {
                  name = "tuesday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "tuesday";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | Tuesday -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> Tuesday);
                };
              Schema.Case
                {
                  name = "wednesday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "wednesday";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | Wednesday -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> Wednesday);
                };
              Schema.Case
                {
                  name = "thursday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "thursday";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | Thursday -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> Thursday);
                };
              Schema.Case
                {
                  name = "friday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "friday";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | Friday -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> Friday);
                };
              Schema.Case
                {
                  name = "saturday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "saturday";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | Saturday -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> Saturday);
                };
              Schema.Case
                {
                  name = "sunday";
                  schema =
                    (let open Schema in
                    {
                      descriptor = String_const "sunday";
                      id = None;
                      parametric = None;
                    });
                  encoder =
                    (function
                    | Sunday -> Some ()
                    | _ -> None);
                  decoder =
                    (function
                    | () -> Sunday);
                };
            ];
          key = None;
        }
    and id = "weekday" in
    Schema.{ descriptor; id = Some id; parametric = None }

  let schema_string = schema
end

module type WEEKDAY = sig
  (** @inline *)
  include Types_bare.WEEKDAY

  (** Schema mapping week days to their english name. *)
  val schema_string : t Schematic.Schema.t

  (** [schema] is [schema_int]. *)
  val schema : t Schematic.Schema.t
end
