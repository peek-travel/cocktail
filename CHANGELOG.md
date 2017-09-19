# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- Added `Schedule.end_all_recurrence_rules/2` which adds an `:until` option to
  each recurrence rule in a schedule.

## [0.3.0] - 2017-09-14
### Added
- Added the "minute of hour" option (`BYMINUTE` in iCalendar)
- Added the "second of minute" option (`BYSECOND` in iCalendar)

## [0.2.1] - 2017-09-12
### Added
- Added logo to documentation

## [0.2.0] - 2017-09-11
### Added
- Better documentation to `Schedule.occurrences/1` to explain the duration option on schedules.

## 0.0.1 - 2017-09-08
### Initial release

[Unreleased]: https://github.com/peek-travel/cocktail/compare/0.3.0...HEAD
[0.3.0]: https://github.com/peek-travel/cocktail/compare/0.2.1...0.3.0
[0.2.1]: https://github.com/peek-travel/cocktail/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/peek-travel/cocktail/compare/0.1.0...0.2.0
