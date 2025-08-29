(** Backward compatibility versions *)

module V1_2 = struct
  (** {1 Data types} *)

  (** A day of a month of a year. *)
  module Date = Date

  (** A day of the day. *)
  module Daytime = Daytime

  (** A month. *)
  module Month = Month

  (** A duration. *)
  module Span = Span

  (** A point in time. *)
  module Time = Time

  (** A timezone. *)
  module Timezone = Timezone

  (** A week of a year. *)
  module Week = Week

  (** A day of the week. *)
  module Weekday = Weekday
end

module V1_1 = struct
  include V1_2

  module Daytime = struct
    include Daytime

    let to_time ~timezone date t =
      match to_time ~timezone date t with
      | Result.Ok time -> time
      | Result.Error error -> failwith error
  end
end

module V1_0 = struct
  include V1_1

  (* [Timmy.Timezone.name] was introduced in 1.1 *)
  (* [Timmy.Timezone.of_implementation] did not have a [?name] argument *)
  module Timezone : sig
    type t = Timezone.t

    val of_gmt_offset_seconds : int -> t

    val of_implementation :
      offset_calendar_time_s:
        (date:int * int * int -> time:int * int * int -> int) ->
      offset_timestamp_s:(unix_timestamp:Int64.t -> int) ->
      t

    val utc : t

    val gmt_offset_seconds_at_datetime :
      t -> date:int * int * int -> time:int * int * int -> int

    val gmt_offset_seconds_at_time : t -> Ptime.t -> int
  end = struct
    include Timezone

    let of_implementation ~offset_calendar_time_s ~offset_timestamp_s =
      of_implementation ~offset_calendar_time_s ~offset_timestamp_s ""
  end
end
