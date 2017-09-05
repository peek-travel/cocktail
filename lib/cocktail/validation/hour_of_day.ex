defmodule Cocktail.Validation.HourOfDay do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type hour_number :: 0..23

  @type t :: %__MODULE__{ hour: hour_number }

  @enforce_keys [:hour]
  defstruct hour: nil

  def new(hour), do: %__MODULE__{ hour: hour }

  def next_time(%__MODULE__{ hour: hour }, time, _) do
    diff = hour - time.hour |> mod(24)
    shift_by(diff, :hours, time)
    # TODO: this might also need a "beginning of hour" on it like `day.ex`
  end
end
