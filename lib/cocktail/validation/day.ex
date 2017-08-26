defmodule Cocktail.Validation.Day do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  defstruct [:day]

  def new(day), do: %__MODULE__{ day: normalize_day(day) }

  def next_time(%__MODULE__{ day: day }, time, _) do
    time_wday = Timex.weekday(time)
    diff = mod(day - time_wday, 7)

    time |> shift(days: diff)
  end

  defp normalize_day(:sunday), do: 0
  defp normalize_day(:monday), do: 1
  defp normalize_day(:tuesday), do: 2
  defp normalize_day(:wednesday), do: 3
  defp normalize_day(:thursday), do: 4
  defp normalize_day(:friday), do: 5
  defp normalize_day(:saturday), do: 6
  defp normalize_day(day) when is_integer(day), do: day
end
