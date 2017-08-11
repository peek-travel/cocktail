defmodule Cocktail.Rules.Daily do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  defstruct [ interval: 1 ]

  def new do
    %__MODULE__{}
  end

  def next_time(%__MODULE__{} = _rule, start_time, time) do
    time
    |> lock_seconds(start_time)
    |> lock_minutes(start_time)
    |> lock_hours(start_time)
    |> evaluate_interval(start_time)
  end

  defp lock_seconds(time, start_time), do: time |> shift(seconds: mod(start_time.second - time.second, 60))
  defp lock_minutes(time, start_time), do: time |> shift(minutes: mod(start_time.minute - time.minute, 60))
  defp lock_hours(time, start_time), do: time |> shift(hours: mod(start_time.hour - time.hour, 24))
  defp evaluate_interval(time, start_time), do: time # TODO
end
