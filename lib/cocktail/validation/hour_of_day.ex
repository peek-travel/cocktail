defmodule Cocktail.Validation.HourOfDay do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  @type hour_number :: 0..23

  @type t :: %__MODULE__{ hour: hour_number }

  @enforce_keys [:hour]
  defstruct hour: nil

  def new(hour), do: %__MODULE__{ hour: hour }

  def next_time(%__MODULE__{ hour: hour }, time, _), do: time |> shift(hours: mod(hour - time.hour, 24))
end
