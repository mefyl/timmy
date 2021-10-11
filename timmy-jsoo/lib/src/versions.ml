(** Backward compatibility versions *)

module V0_10_5 = struct
  module Date = struct
    include Timmy.Versions.V0_10_5.Daytime
    include Date
  end

  module Daytime = Timmy.Versions.V0_10_5.Daytime
  module Span = Timmy.Versions.V0_10_5.Span
  module Time = Timmy.Versions.V0_10_5.Time
  module Timezone = Timmy.Versions.V0_10_5.Timezone
  module Weekday = Timmy.Versions.V0_10_5.Weekday

  type date = Timmy.Versions.V0_10_5.date [@@deriving schema]
end

module V0_10_4 = struct
  (** @inline *)
  include V0_10_5

  module Date = struct
    include Timmy.Versions.V0_10_4.Date
    include Date
  end
end

module V0_10_3 = struct
  (** @inline *)
  include V0_10_4

  module Month = Timmy.Versions.V0_10_3.Month
  module Weekday = Timmy.Versions.V0_10_3.Weekday
end

module V0_10_2 = V0_10_3

module V0_10_1 = struct
  (** @inline *)
  include V0_10_2

  module Weekday = Timmy.Versions.V0_10_2.Weekday
end

module V0_10_0 = V0_10_1
