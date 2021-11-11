(** Backward compatibility versions *)

module V0_11_0 = struct
  module Date = Date
  module Daytime = Timmy.Daytime
  module Month = Timmy.Month
  module Span = Timmy.Span
  module Time = Time
  module Timezone = Timmy.Timezone
  module Weekday = Timmy.Weekday
end
