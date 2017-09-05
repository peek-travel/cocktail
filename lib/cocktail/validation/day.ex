defmodule Cocktail.Validation.Day do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type t :: %__MODULE__{ day: Cocktail.day_number }

  @enforce_keys [:day]
  defstruct day: nil

  @spec new(Cocktail.day) :: t
  def new(day), do: %__MODULE__{ day: day_number(day) }

  @spec next_time(t, DateTime.t, DateTime.t) :: Cocktail.Validation.Shift.result
  def next_time(%__MODULE__{ day: day }, time, _) do
    diff = day - Timex.weekday(time) |> mod(7)
    shift_by_bod(diff, :days, time)
  end

  @spec day_number(Cocktail.day) :: Cocktail.day_number
  defp day_number(:sunday), do: 0
  defp day_number(:monday), do: 1
  defp day_number(:tuesday), do: 2
  defp day_number(:wednesday), do: 3
  defp day_number(:thursday), do: 4
  defp day_number(:friday), do: 5
  defp day_number(:saturday), do: 6
  defp day_number(day) when is_integer(day), do: day
end
