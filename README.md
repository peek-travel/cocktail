# Cocktail

> NOTE: this is a temporary place for it while we work on it.  Once ready for prime-time, we will open-source this and move it to the peek-travel public repo.

Elixir date recurrence library based on iCal specification.

# Goals

* export schedules as iCal format
* import schedules from iCal format
* generate list of schedule occurrences within a date range very quickly
* programmtic way of creating schedules

## Help

* Right now I'm just working on understanding iCal better.  See examples here: [examples.md](examples.md)

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
