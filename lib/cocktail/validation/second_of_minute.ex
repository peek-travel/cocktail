defmodule Cocktail.Validation.SecondOfMinute do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type t :: %__MODULE__{second: Cocktail.second_number}

  @enforce_keys [:second]
  defstruct second: nil

  @spec new(Cocktail.second_number) :: t
  def new(second), do: %__MODULE__{second: second}

  @spec next_time(t, Cocktail.time, Cocktail.time) :: Cocktail.Validation.Shift.result
  def next_time(%__MODULE__{second: second}, time, _) do
    diff = second - time.second |> mod(60)
    shift_by(diff, :seconds, time)
  end
end
