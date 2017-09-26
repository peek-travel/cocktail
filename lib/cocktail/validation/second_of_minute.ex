defmodule Cocktail.Validation.SecondOfMinute do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift
  import Cocktail.Util, only: [next_gte: 2]

  @type t :: %__MODULE__{seconds: [Cocktail.second_number]}

  @enforce_keys [:seconds]
  defstruct seconds: nil

  @spec new([Cocktail.second_number]) :: t
  def new(seconds), do: %__MODULE__{seconds: seconds |> Enum.sort}

  @spec next_time(t, Cocktail.time, Cocktail.time) :: Cocktail.Validation.Shift.result
  def next_time(%__MODULE__{seconds: seconds}, time, _) do
    current_second = time.second
    second = next_gte(seconds, current_second) || hd(seconds)
    diff = second - current_second |> mod(60)

    shift_by(diff, :seconds, time)
  end
end
