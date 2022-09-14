(** Backward compatibility versions *)

module V0_13_3 = struct
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

module V0_13_2 = V0_13_3
module V0_13_1 = V0_13_2
module V0_13_0 = V0_13_1
