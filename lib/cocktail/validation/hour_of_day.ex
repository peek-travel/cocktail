defmodule Cocktail.Validation.HourOfDay do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type t :: %__MODULE__{hour: Cocktail.hour_number}

  @enforce_keys [:hour]
  defstruct hour: nil

  @spec new(Cocktail.hour_number) :: t
  def new(hour), do: %__MODULE__{hour: hour}

  @spec next_time(t, Cocktail.time, Cocktail.time) :: Cocktail.Validation.Shift.result
  def next_time(%__MODULE__{hour: hour}, time, _) do
    diff = hour - time.hour |> mod(24)
    shift_by(diff, :hours, time)
    # TODO: this might also need a "beginning of hour" on it like `day.ex`
  end
end
