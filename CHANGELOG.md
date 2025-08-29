# Changelog

## [1.2.0] - 2025-08-29

### Added

- `Timmy.Time.timestamp_schema` to code times as an Epoch-based
  timestamp.

### Changed

- `Timmy.Daytime.to_time` to return a `Result.Error` instead of
  raising an exception in case of error.

### Fixed

- `Clock.timezone_local` choking on null timestamp on windows.

## [1.1.9] - 2025-07-02

### Added

- `Weekday.of_int`
- `Weekday.add_days`

## [1.1.8] - 2025-01-11

### Changed

- Build system in favor of `dune pkg`.

## [1.1.5] - 2024-10-09

### Fixed

- OCaml 4.08 compatibility.

### Removed

- Landmarks dependency.

## [1.1.4] - 2024-10-09

### Added

- Windows support for `timmy-unix`.

### Changed

- `Timmy.Span.pp` to display fractional seconds.

### Fixed

- Missing `logs` dependency.
- Missing `Js.float` conversions, for wasm-of-ocaml.

## [1.1.3] - 2024-02-29

## Fixed

- Pins for landmarks.
- Some documentation links.

## [1.1.2] - 2023-12-25

### Added

- `Timmy_lwt.Ticker.finalise`.
- `Timmy_lwt.Ticker.pause`.

### Fixed

- Schemas of `Date.t` and `Datetime.t` to return `Result.Error`s
  instead of raising `Failure`s.


## [1.1.1] - 2023-10-25

### Fixed

- `Timmy_lwt.Ticker.stop` not actually stopping after the first tick.

## [1.1.0] - 2023-10-25

### Added

- `Timezone.name` to retrieve IANA timezone names.

## [1.0.4] - 2023-09-19

### Fixed

- OCaml 0.5.1 compatibility.

## [1.0.3] - 2023-08-31

### Fixed

- Timezone offset computation in `timmy-unix`.

## [1.0.2] - 2023-07-04

### Fixed

- Inverted fields in `Timmy.Week.t` schema.

## [1.0.1] - 2023-06-23

### Fixed

- Pretty printing of the null `Timmy.Span.t`.

## [1.0.0] - 2023-04-14

### Added

- First release of the `timmy`, `timmy-jsoo` and `timmy-unix` libraries.
