(** Backward compatibility versions *)

module V0_10_3 = struct
  module Date = Date
  module Daytime = Timmy.Versions.V0_10_3.Daytime
  module Span = Timmy.Versions.V0_10_3.Span
  module Time = Time
  module Timezone = Timmy.Versions.V0_10_3.Timezone
  module Weekday = Timmy.Versions.V0_10_3.Weekday

  type date = Timmy.Versions.V0_10_3.date [@@deriving schema]
end

module V0_10_2 = V0_10_3

module V0_10_1 = struct
  (** @inline *)
  include V0_10_2

  module Weekday = Timmy.Versions.V0_10_2.Weekday
end

module V0_10_0 = V0_10_1
