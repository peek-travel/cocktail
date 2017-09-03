defmodule Cocktail.Validation.Interval do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  defstruct [:type, :interval]

  def new(type, interval), do: %__MODULE__{ type: type, interval: interval }

  def next_time(%__MODULE__{ type: :weekly, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :weeks)
  def next_time(%__MODULE__{ type: :daily, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :days)
  def next_time(%__MODULE__{ type: :hourly, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :hours)
  def next_time(%__MODULE__{ type: :minutely, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :minutes)
  def next_time(%__MODULE__{ type: :secondly, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :seconds)

  defp apply_interval(time, _, 1, _), do: time

  defp apply_interval(time, start_time, interval, :weeks) do
    {_, start_weeknum} = Timex.iso_week(start_time) # TODO: sunday week start
    {_, current_weeknum} = Timex.iso_week(time)
    diff = current_weeknum - start_weeknum # TODO: rollover
    off_by = mod(diff, interval)

    shift(time, days: off_by * 7)
  end

  defp apply_interval(time, start_time, interval, type) do
    off_by =
      start_time
      |> Timex.diff(time, type)
      |> mod(interval)

    shift(time, "#{type}": off_by)
  end
end
