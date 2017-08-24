defmodule Cocktail.Validation.Interval do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]
  import Timex.Interval, only: [duration: 2]

  alias Timex.Interval

  def apply_interval(time, _, 1, _), do: time
  def apply_interval(time, start_time, interval, type) do
    off_by =
      [from: start_time, until: time]
      |> Interval.new # TODO: Timex.Intervals are weird, this may not be doing what we want in all cases, consider Timex.diff instead
      |> duration(type)
      |> mod(interval)

    shift(time, "#{type}": off_by)
  end
end
