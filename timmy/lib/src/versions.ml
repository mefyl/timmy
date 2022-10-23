(** Backward compatibility versions *)

module V0_14_2 = struct
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

module V0_14_1 = struct
  include V0_14_2

  module Date = struct
    include Date

    let of_tuple_exn ~here = of_tuple_exn ~here
  end

  module Daytime = struct
    include Daytime

    let of_tuple_exn ~here = of_tuple_exn ~here
  end
end

module V0_14_0 = V0_14_1
