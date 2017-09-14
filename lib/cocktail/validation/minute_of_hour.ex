defmodule Cocktail.Validation.MinuteOfHour do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type t :: %__MODULE__{minute: Cocktail.minute_number}

  @enforce_keys [:minute]
  defstruct minute: nil

  @spec new(Cocktail.minute_number) :: t
  def new(minute), do: %__MODULE__{minute: minute}

  @spec next_time(t, Cocktail.time, Cocktail.time) :: Cocktail.Validation.Shift.result
  def next_time(%__MODULE__{minute: minute}, time, _) do
    diff = minute - time.minute |> mod(60)
    shift_by(diff, :minutes, time)
    # TODO: this might also need a "beginning of minute" on it like `day.ex`
  end
end
