(** Backward compatibility versions *)

module V0_10 = struct
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

  (** A day of the week. *)
  module Weekday = Weekday

  (** {1 Type shortcuts} *)

  type date = Date.t [@@deriving schema]
end
