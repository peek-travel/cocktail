defmodule Cocktail.Validation.Day do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  defstruct [:day]

  def new(day), do: %__MODULE__{ day: day_number(day) }

  def next_time(%__MODULE__{ day: day }, time, _) do
    time_wday = Timex.weekday(time)
    diff = mod(day - time_wday, 7)

    time |> shift(days: diff)
  end

  defp day_number(:sunday), do: 0
  defp day_number(:monday), do: 1
  defp day_number(:tuesday), do: 2
  defp day_number(:wednesday), do: 3
  defp day_number(:thursday), do: 4
  defp day_number(:friday), do: 5
  defp day_number(:saturday), do: 6
  defp day_number(day) when is_integer(day), do: day
end
