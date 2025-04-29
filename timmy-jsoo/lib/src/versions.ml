(** Backward compatibility versions *)

module V1_1 = struct
  module Date = Date
  module Daytime = Daytime
  module Month = Timmy.Month
  module Span = Timmy.Span
  module Time = Time
  module Timezone = Timezone
  module Week = Week
  module Weekday = Timmy.Weekday
end

module V1_0 = V1_1
