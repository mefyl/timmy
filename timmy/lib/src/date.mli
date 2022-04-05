open Base

(** {1 Type} *)

(** @inline *)
include Type.DATE

(** @inline *)
include module type of Type_js.Date

(** {1 Construction} *)

(** [make ~year ~month ~day] is [{ day; month; year }] if it represents a valid
    date or a relevant error message otherwise. *)
val make : year:int -> month:Month.t -> day:int -> (t, string) Result.t

(** [make_overflow] is {!make} except out of range components will readjust the
    next component until the date becomes valid. This enables to perform simple
    arithmetics over dates like adding or substracting days and months without
    worrying about month and year boundaries and readjust the final results.

    Month below 1 will underflow to previous years and month above 12 will
    overflow to the next years, eg. [make ~year:2021 ~month:-1
   ~day:1 ()] is
    [{year = 2020; month = 11; day = 1}] and
    [make
   ~year:2021 ~month:25 ~day:1 ()] is
    [{year = 2023; month = 1; day =
   1}].

    Unless [truncate_day] is true, days below 1 will underflow to the previous
    months and days past the last day of the month will overflow to the next
    months, eg. [make_overflow ~year:1985 ~month:2
   ~day:29 ()] is
    [{year = 1985; month = 3; day = 1}].

    If [truncate_day] is true, the day is clipped to the valid range for the
    current month. This is useful to do arithmetics on months without risking
    the day overflowing to the next months if the new month is shorter, eg.
    [make_overflow ~day_truncate:true ~year:1985 ~month:(1 + 1) ~day:31 ()] is
    [{year = 1985;
   month = 2; day = 28}]. *)
val make_overflow :
  ?day_truncate:bool -> year:int -> month:int -> day:int -> unit -> t

(** {1 Time manipulations} *)

(** [add_days date n] is the date occuring [n] days after [date]. *)
val add_days : t -> int -> t

(** [max_month_day year month] is the last day of the given [month] of [year].
    It can be 31, 30, 29 or 28. *)
val max_month_day : int -> int -> int

(** [weekday date] is the day of the week on [date]. *)
val weekday : t -> Weekday.t

(** {2 Time conversions} *)

(** [of_time ~timezone date] is the date on [date] in [timezone].

    @raise Failure if the [date] does not exist in [timezone]. *)
val of_time : timezone:Timezone.t -> Time.t -> t

(** [to_time ~timezone date] is the time at midnight on [date] in [timezone].

    @raise Failure if the [date] does not exist in [timezone]. *)
val to_time : timezone:Timezone.t -> t -> Time.t

(** {2 Comparison} *)

include Base.Comparable.S with type t := t

(** {2 Operators} *)

(** Convenience module to only pull operators. *)
module O : sig
  include Comparable.Infix with type t := t

  (** [date + n] is [add_days date n]. *)
  val ( + ) : t -> int -> t

  (** [end - start] is the duration elapsed from [start] to [end]. *)
  val ( - ) : t -> t -> Span.t
end

include module type of O

(** {1 Scalar conversions} *)

(** {2 Pretty-print} *)

(** [pp f date] prints [date] to [f] in RFC3339 format, eg. 2021-10-04. *)
val pp : t Fmt.t

(** {2 String} *)

(** [to_string date] is the RCF3339 representation of [date], eg. 2021-10-04. *)
val to_string : t -> string

(** [of_string s] is the date represented by [s] as per RCF3339 or a relevant
    error message if it is invalid. *)
val of_string : string -> (t, string) Result.t

(** {2 Tuple} *)

(** [to_tuple { year; month; day}] is [(year, Month.to_int month, day)]. *)
val to_tuple : t -> int * int * int

(** [of_tuple (year, month, day)] is the corresponding date if it is valid or a
    relevant error message otherwise. *)
val of_tuple : int * int * int -> (t, string) Result.t

(** [of_tuple (year, month, day)] is the corresponding date.

    @raise Failure if the date is invalid. *)
val of_tuple_exn : here:Source_code_position.t -> int * int * int -> t

(** {2 S-expression} *)

(** [to_sexp date] is a s-expression representing [date]. *)
val to_sexp : t -> Sexp.t

(** {2 Integer} *)

(** [to_int date] is the {{:https://en.wikipedia.org/wiki/Julian_day} Julian
    day} of [date]. *)
val to_int : t -> int

(** [of_int jd] is the date of the {{:https://en.wikipedia.org/wiki/Julian_day}
    Julian day} [jd]. *)
val of_int : int -> t
