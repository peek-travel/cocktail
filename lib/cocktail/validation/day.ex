defmodule Cocktail.Validation.Day do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type day_number :: 0..6

  @type t :: %__MODULE__{ day: day_number }

  @enforce_keys [:day]
  defstruct day: nil

  def new(day), do: %__MODULE__{ day: day_number(day) }

  def next_time(%__MODULE__{ day: day }, time, _) do
    diff = day - Timex.weekday(time) |> mod(7)
    shift_by_bod(diff, :days, time)
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
