defmodule Cocktail.Validation.HourOfDay do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  defstruct [:hour]

  def new(hour), do: %__MODULE__{ hour: hour }

  def next_time(%__MODULE__{ hour: hour }, time, _), do: time |> shift(hours: mod(hour - time.hour, 24))
end
