defmodule Cocktail.Validation.ScheduleLock do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  defstruct [:type]

  def new(type), do: %__MODULE__{ type: type }

  def next_time(%__MODULE__{ type: :second }, time, start_time), do: time |> shift(seconds: mod(start_time.second - time.second, 60))
  def next_time(%__MODULE__{ type: :minute }, time, start_time), do: time |> shift(minutes: mod(start_time.minute - time.minute, 60))
  def next_time(%__MODULE__{ type: :hour }, time, start_time), do: time |> shift(hours: mod(start_time.hour - time.hour, 24))
  def next_time(%__MODULE__{ type: :wday }, time, start_time) do
    start_time_day = Timex.weekday(start_time)
    time_day = Timex.weekday(time)
    diff = mod(start_time_day - time_day, 7)

    time |> shift(days: diff)
  end
end
