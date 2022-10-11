(** Timmy is a time manipulation library aiming at correctness and convenience. *)

(** {1 Concepts}

    {!Timmy} strictly separate abstract points in time ({!Timmy.Time.t}) from
    calendar dates and related notions such as week days. *)

(** {1 API} *)

(** @inline *)
include Versions.V0_14_0

(** {1 Backward compatibility} *)

module Versions = Versions
