# ![Cocktail](./logo_with_border.png) Cocktail
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
    {:cocktail, "~> 0.6"}
  ]
end
```

## Documentation

Detailed documentation with all available options can be found at [https://hexdocs.pm/cocktail](https://hexdocs.pm/cocktail).

## Quick-start Guide

### Schedules

Everything starts with a [Cocktail.Schedule](https://hexdocs.pm/cocktail/Cocktail.Schedule.html); create one like this:

```elixir
iex> schedule = Cocktail.schedule(start_time, opts)
#Cocktail.Schedule<>

# or
...> schedule = Cocktail.Schedule.new(start_time, opts)
#Cocktail.Schedule<>
```

*   `start_time` - Either a `DateTime` or a `NaiveDateTime` representing the beginning of your schedule.
*   `opts`:
    *   `duration` - (optional) How long each occurrence is, in seconds.

### Recurrence Rules

Schedules are pretty useless on their own. To have them do something useful, you add recurrence rules to them. Currently, Cocktail supports:

*   Weekly
*   Daily
*   Hourly
*   Minutely
*   Secondly

On top of these basic recurrence frequencies, you can add various options. Let's see some examples:

```elixir
iex> every_other_day = Cocktail.Schedule.add_recurrence_rule(schedule, :daily, interval: 2)
#Cocktail.Schedule<Every 2 days>

...> weekly_on_mo_we_fr = Cocktail.Schedule.add_recurrence_rule(schedule, :weekly, days: [:monday, :wednesday, :friday])
#Cocktail.Schedule<Weekly on Mondays, Wednesdays and Fridays>

...> daily_at_9am_and_5pm = Cocktail.Schedule.add_recurrence_rule(schedule, :daily, hours: [9, 17])
#Cocktail.Schedule<Daily on the 9th and 17th hours of the day>
```

For more details about frequencies and options, see [Cocktail.Schedule.add_recurrence_rule/3](https://hexdocs.pm/cocktail/Cocktail.Schedule.html#add_recurrence_rule/3)

### Occurrences

Once you've got a schedule set up the way you want, you can generate a stream of occurrences that match the schedule like so:

```elixir
iex> occurrences = Cocktail.Schedule.occurrences(schedule)
#Function<60.51599720/2 in Stream.unfold/2>
...> Enum.take(occurrences, 3)
[~N[2017-01-01 00:00:00], ~N[2017-01-02 00:00:00], ~N[2017-01-03 00:00:00]]
```

The type of each occurrence depends on what start time type you used, and wether or not you supplied a duration when creating the schedule.

### Duration

If you add the `duration` option when creating a schedule, you'll get `Cocktail.Span` structs as occurrences, with `:from` and `:until` fields of the same type as your start time.

```elixir
iex> schedule = Cocktail.schedule(~N[2017-01-01 00:00:00], duration: 3600) |> Cocktail.Schedule.add_recurrence_rule(:daily)
#Cocktail.Schedule<Daily>
...> occurrences = Cocktail.Schedule.occurrences(schedule)
#Function<60.51599720/2 in Stream.unfold/2>
...> Enum.take(occurrences, 3)
[%Cocktail.Span{from: ~N[2017-01-01 00:00:00], until: ~N[2017-01-01 01:00:00]},
 %Cocktail.Span{from: ~N[2017-01-02 00:00:00], until: ~N[2017-01-02 01:00:00]},
 %Cocktail.Span{from: ~N[2017-01-03 00:00:00], until: ~N[2017-01-03 01:00:00]}]
```

### Recurrence Times and Exception Times

You can also add one-off recurrence times that don't fit into a normal recurrence pattern, and exception times if you want to exclude a time that would normally be included because of a recurrence rule:

```elixir
iex> schedule = Cocktail.schedule(~N[2017-01-01 08:00:00]) |> Cocktail.Schedule.add_recurrence_rule(:daily)
#Cocktail.Schedule<Daily>
...> schedule = [~N[2017-01-01 09:00:00], ~N[2017-01-02 11:00:00], ~N[2017-01-03 17:00:00]] |> Enum.reduce(schedule, &Cocktail.Schedule.add_recurrence_time(&2, &1))
#Cocktail.Schedule<Daily>
...> schedule = Cocktail.Schedule.add_exception_time(schedule, ~N[2017-01-02 08:00:00])
#Cocktail.Schedule<Daily>
...> Cocktail.Schedule.occurrences(schedule) |> Enum.take(6)
[~N[2017-01-01 08:00:00], ~N[2017-01-01 09:00:00], ~N[2017-01-02 11:00:00],
 ~N[2017-01-03 08:00:00], ~N[2017-01-03 17:00:00], ~N[2017-01-04 08:00:00]]
```

### iCalendar

You can convert schedules to and from the iCalendar format like this:

```elixir
iex> i_calendar = Cocktail.Schedule.to_i_calendar(schedule)
"DTSTART:20170101T000000\nRRULE:FREQ=DAILY"

...> Cocktail.Schedule.from_i_calendar(i_calendar)
{:ok, #Cocktail.Schedule<Daily>}
```

## Roadmap

*   [ ] investigate and fix DST bugs when using zoned DateTime
*   [ ] support all iCalendar RRULE options
*   [ ] support week-start option
*   [ ] support iCalendar EXRULE
*   [ ] convert to/from JSON representation

## Credits

Cocktail is heavily inspired by and based on a very similar Ruby library, [ice_cube](https://github.com/seejohnrun/ice_cube).

## License

[MIT](LICENSE.md)
