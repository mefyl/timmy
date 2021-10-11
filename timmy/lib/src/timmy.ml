(** Timmy is a time manipulation library aiming at correctness and convenience. *)

(** {1 Concepts}

    {!Timmy} strictly separate abstract points in time ({!Timmy.Time.t}) from
    calendar dates and related notions such as week days. *)

(** {1 API} *)

(** @inline *)
include Versions.V0_10_7

(** {1 Backward compatibility} *)

module Versions = Versions

(** {1 Relation with Ptime and rationale}

    {!Timmy} is entirely based on {!Ptime} and thus supports POSIX timestamps
    with picosecond precision in a platform independent manner. It intends to
    provide a slightly higher level interface, more type safety and convenience
    functions.

    - It is impossible to map dates to and from time points without specifying a
      timezone. Many such Ptime functions have an optional timezone argument or
      omit it entirely.
    - Types are private records instead of tuples. This *)
