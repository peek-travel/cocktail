# Cocktail
[![Build Status](https://travis-ci.org/peek-travel/cocktail.svg?branch=master)](https://travis-ci.org/peek-travel/cocktail) [![codecov](https://codecov.io/gh/peek-travel/cocktail/branch/master/graph/badge.svg)](https://codecov.io/gh/peek-travel/cocktail) [![Hex.pm Version](https://img.shields.io/hexpm/v/cocktail.svg?style=flat)](https://hex.pm/packages/cocktail) [![Inline docs](http://inch-ci.org/github/peek-travel/cocktail.svg)](http://inch-ci.org/github/peek-travel/cocktail)

Cocktail is an Elixir date recurrence library based on [iCalendar events](https://tools.ietf.org/html/rfc5545#section-3.6.1). It's primary use case currently is to expand schedules with recurrence rules into streams of ocurrences. For example: say you wanted to represent a repeating schedule of events that occurred every other week, on Mondays, Wednesdays and Fridays, at 10am and 4pm.

```elixir
iex> schedule = Cocktail.Schedule.new(~N[2017-01-02 10:00:00])
...> schedule = Cocktail.Schedule.add_recurrence_rule(schedule, :weekly, interval: 2, days: [:monday, :wednesday, :friday], hours: [10, 16])
#Cocktail.Schedule<Every 2 weeks on Mondays, Wednesdays and Fridays on the 10th and 16th hours of the day>
```

Then to get a list of the first 10 occurrences of this schedule, you would do:
```elixir
...> stream = Cocktail.Schedule.occurrences(schedule)
...> Enum.take(stream, 10)
[~N[2017-01-02 10:00:00], ~N[2017-01-02 16:00:00], ~N[2017-01-04 10:00:00],
 ~N[2017-01-04 16:00:00], ~N[2017-01-06 10:00:00], ~N[2017-01-06 16:00:00],
 ~N[2017-01-16 10:00:00], ~N[2017-01-16 16:00:00], ~N[2017-01-18 10:00:00],
 ~N[2017-01-18 16:00:00]]
```

## Installation

Cocktail is [available in Hex](https://hex.pm/packages/cocktail) and can be installed
by adding `cocktail` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cocktail, "~> 0.2.0"}
  ]
end
```

## Documentation

Detailed documentation with all available options can be found at [https://hexdocs.pm/cocktail](https://hexdocs.pm/cocktail).

## Roadmap

* [ ] 100% test coverage
* [ ] investigate and fix DST bugs
* [ ] add the rest of the iCalendar RRULE options
* [ ] more / better docs and more examples (getting started guide)

## Credits

Cocktail is heavily inspired by and based on a very similar Ruby library, [ice_cube](https://github.com/seejohnrun/ice_cube).

## License

[MIT](LICENSE.md)
