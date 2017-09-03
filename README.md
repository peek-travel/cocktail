# Cocktail

![cocktail](https://user-images.githubusercontent.com/221693/29235380-00d58c3c-7eb3-11e7-8366-007c6d010efc.jpg)

> NOTE: this is a temporary place for it while we work on it.  Once ready for prime-time, we will open-source this and move it to the peek-travel public repo.

Elixir date recurrence library based on iCalendar specification.

# Goals

* export schedules as iCalendar format
* import schedules from iCalendar format
* generate list of schedule occurrences within a date range very quickly
* programmtic way of creating schedules

## TODO

* [ ] 100% test coverage
* [ ] fault tolerent iCalendar parsing
* [ ] types and specs everywhere
* [ ] fix DST and other bugs
* [ ] performance
* [ ] the rest of the iCalendar RRULE options

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `cocktail` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:cocktail, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/cocktail](https://hexdocs.pm/cocktail).
