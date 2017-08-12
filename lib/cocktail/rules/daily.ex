defmodule Cocktail.Rules.Daily do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]
  import Timex.Interval, only: [duration: 2]

  alias Timex.Interval

  defstruct [ interval: 1 ]

  def new(options) do
    interval = Keyword.get(options, :interval, 1)
    %__MODULE__{ interval: interval }
  end

  def next_time(%__MODULE__{ interval: interval }, start_time, time) do
    time
    |> lock_seconds(start_time)
    |> lock_minutes(start_time)
    |> lock_hours(start_time)
    |> apply_interval(start_time, interval)
  end

  defp lock_seconds(time, start_time), do: time |> shift(seconds: mod(start_time.second - time.second, 60))
  defp lock_minutes(time, start_time), do: time |> shift(minutes: mod(start_time.minute - time.minute, 60))
  defp lock_hours(time, start_time), do: time |> shift(hours: mod(start_time.hour - time.hour, 24))

  defp apply_interval(time, start_time, 1), do: time
  defp apply_interval(time, start_time, interval) do
    off_by =
      [from: start_time, until: time]
      |> Interval.new
      |> duration(:days)
      |> mod(interval)

    shift(time, days: off_by)
  end
end
