# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased][]

## [0.10.0][] - 2021-06-18

### Added

-   Ability to get RRULE string [#174](https://github.com/peek-travel/cocktail/pull/174) (thanks to @yordis)
-   Expose Rule struct to docs
    [#170](https://github.com/peek-travel/cocktail/pull/170) (thanks to @yordis)

### Fixed

-   Fixed a timezone / DST related bug [#160](https://github.com/peek-travel/cocktail/pull/160) (thanks to @peaceful-james)

### Updated

-   GitHub Actions update / refactor [#164](https://github.com/peek-travel/cocktail/pull/164) (thanks to @vanvoljg)

## [0.9.0][] - 2020-11-21

### Added

-   Monthly recurrences (thanks to @peaceful-james, @bruteforcecat and @Stroemgren!)

### Fixed

-   Bug in `Builder.String` when there's only a single day (thanks to @chime-gm!)

## [0.8.4][] - 2019-06-14

### Updated

-   Dependency updates and credo refactors

## [0.8.3][] - 2018-11-12

### Fixed

-   Allow additional keys in Cocktail.Span.span_compat type

## [0.8.2][] - 2018-11-08

### Fixed

-   Fix a couple typespecs in Cocktail.Span ([#66](https://github.com/peek-travel/cocktail/pull/66))

## [0.8.1][] - 2018-02-17

### Fixed

-   Allow backwards compatible parsing of BYTIME rule for existing schedules generated using cocktail pre-0.8.

## [0.8.0][] - 2018-02-17

### Breaking

-   The `BYTIME` option of `RRULE`s in the iCalendar output is now `X-BYTIME` to better follow the standard's extensions policy

### Added

-   "time range" option (e.g. `Schedule.add_recurrence_rules(:daily, time_range: %{start_time: ~T[09:00:00], end_time: ~T[11:00:00], interval_seconds: 1_800})`; this serializes to `X-BYRANGE` in iCalendar format, using the extension prefix to signal that it's a proprietary extension)

### Changed

-   Formatted code-base with the new Elixir 1.6 code formatter
-   Changed `Schedule.t()` to not be an opaque type, which fixed the few missing typespecs

### Removed

-   JSON parser and builder; it was incomplete (will revisit in the future)

## [0.7.0][] - 2017-12-07

### Added

-   The ability to pass anything responding to `from` and `until` to `overlap_mode` and `compare`

## [0.6.0][] - 2017-10-30

### Added

-   Quick Start guide and logo to the README

### Fixed

-   Some recurrence rules would keep the microsecond component of the start time when generating occurrences. Cocktail now always strips microseconds out, it only supports second precision.

## [0.5.3][] - 2017-10-19

### Fixed

-   Giving empty lists for the :days, :hours, :minutes, :seconds, and :times options would produce invalid iCalendar strings

## [0.5.2][] - 2017-10-06

### Fixed

-   Overriding the start time to before the schedule's start time would cause invalid occurrences to be emitted

## [0.5.1][] - 2017-09-26

### Fixed

-   Removed problematic logging

## [0.5.0][] - 2017-09-26

### Added

-   "time of day" option (e.g. `Schedule.add_recurrence_rules(:daily, times: [~T[10:00:00], ~T[12:30:00]])`; this serializes to `BYTIME` in iCalendar format, which doesn't actually exist, so don't use this if you need to be iCalendar compatible)

### Fixed

-   Improved performance (up to 80x for certain types of schedules)

## [0.4.0][] - 2017-09-19

### Added

-   Added `Schedule.end_all_recurrence_rules/2` which adds an `:until` option to each recurrence rule in a schedule.
-   Added support for one-off recurrence times (`RDATE` in iCalendar)
-   Added support for exception times (`EXDATE` in iCalendar)

## [0.3.0][] - 2017-09-14

### Added

-   Added the "minute of hour" option (`BYMINUTE` in iCalendar)
-   Added the "second of minute" option (`BYSECOND` in iCalendar)

## [0.2.1][] - 2017-09-12

### Added

-   Added logo to documentation

## [0.2.0][] - 2017-09-11

### Added

-   Better documentation to `Schedule.occurrences/1` to explain the duration option on schedules.

## 0.0.1 - 2017-09-08

### Initial release

[Unreleased]: https://github.com/peek-travel/cocktail/compare/0.10.0...HEAD

[0.10.0]: https://github.com/peek-travel/cocktail/compare/0.9.0...0.10.0

[0.9.0]: https://github.com/peek-travel/cocktail/compare/0.8.4...0.9.0

[0.8.4]: https://github.com/peek-travel/cocktail/compare/0.8.3...0.8.4

[0.8.3]: https://github.com/peek-travel/cocktail/compare/0.8.2...0.8.3

[0.8.2]: https://github.com/peek-travel/cocktail/compare/0.8.1...0.8.2

[0.8.1]: https://github.com/peek-travel/cocktail/compare/0.8.0...0.8.1

[0.8.0]: https://github.com/peek-travel/cocktail/compare/0.7.0...0.8.0

[0.7.0]: https://github.com/peek-travel/cocktail/compare/0.6.0...0.7.0

[0.6.0]: https://github.com/peek-travel/cocktail/compare/0.5.3...0.6.0

[0.5.3]: https://github.com/peek-travel/cocktail/compare/0.5.2...0.5.3

[0.5.2]: https://github.com/peek-travel/cocktail/compare/0.5.1...0.5.2

[0.5.1]: https://github.com/peek-travel/cocktail/compare/0.5.0...0.5.1

[0.5.0]: https://github.com/peek-travel/cocktail/compare/0.4.0...0.5.0

[0.4.0]: https://github.com/peek-travel/cocktail/compare/0.3.0...0.4.0

[0.3.0]: https://github.com/peek-travel/cocktail/compare/0.2.1...0.3.0

[0.2.1]: https://github.com/peek-travel/cocktail/compare/0.2.0...0.2.1

[0.2.0]: https://github.com/peek-travel/cocktail/compare/0.1.0...0.2.0
