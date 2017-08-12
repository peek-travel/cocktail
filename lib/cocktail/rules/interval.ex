defmodule Cocktail.Rules.Interval do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]
  import Timex.Interval, only: [duration: 2]

  alias Timex.Interval

  def apply_interval(time, _, 1, _), do: time
  def apply_interval(time, start_time, interval, type) do
    off_by =
      [from: start_time, until: time]
      |> Interval.new
      |> duration(type)
      |> mod(interval)

    shift(time, "#{type}": off_by)
  end
end
