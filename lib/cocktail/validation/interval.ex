defmodule Cocktail.Validation.Interval do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type frequency :: :weekly   |
                     :daily    |
                     :hourly   |
                     :minutely |
                     :secondly

  @type t :: %__MODULE__{ type: frequency, interval: pos_integer }

  @enforce_keys [:type, :interval]
  defstruct type:     nil,
            interval: nil

  def new(type, interval), do: %__MODULE__{ type: type, interval: interval }

  def next_time(%__MODULE__{ type: :weekly, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :weeks)
  def next_time(%__MODULE__{ type: :daily, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :days)
  def next_time(%__MODULE__{ type: :hourly, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :hours)
  def next_time(%__MODULE__{ type: :minutely, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :minutes)
  def next_time(%__MODULE__{ type: :secondly, interval: interval }, time, start_time), do: apply_interval(time, start_time, interval, :seconds)

  defp apply_interval(time, _, 1, _), do: {:no_change, time}

  defp apply_interval(time, start_time, interval, :weeks) do
    {_, start_weeknum} = Timex.iso_week(start_time) # TODO: sunday week start
    {_, current_weeknum} = Timex.iso_week(time)
    diff = current_weeknum - start_weeknum # TODO: rollover
    off_by = mod(diff, interval)

    shift_by(off_by * 7, :days, time)
  end

  defp apply_interval(time, start_time, interval, :days) do
    date = DateTime.to_date(time)
    start_date = DateTime.to_date(start_time)

    diff =
      start_date
      |> Timex.diff(date, :days)
      |> mod(interval)

    shift_by(diff, :days, time)
  end

  defp apply_interval(time, start_time, interval, type) do
    start_time
    |> Timex.diff(time, type)
    |> mod(interval)
    |> shift_by(type, time)
  end
end
