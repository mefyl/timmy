(** Backward compatibility versions *)

module V0_12_1 = struct
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

module V0_12_0 = struct
  include V0_12_1

  module Timezone : sig
    type t = Timezone.t

    val of_gmt_offset_seconds : int -> t
    val to_gmt_offset_seconds : t -> int
    val utc : t
  end = struct
    include Timezone

    let to_gmt_offset_seconds t =
      gmt_offset_seconds_at_datetime ~date:(1970, 1, 1) ~time:(0, 0, 0) t
  end
end
