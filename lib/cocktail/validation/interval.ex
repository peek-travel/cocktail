defmodule Cocktail.Validation.Interval do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @typep interval_shift_type :: :weeks | :days | :hours | :minutes | :seconds

  @type t :: %__MODULE__{type: Cocktail.frequency, interval: pos_integer}

  @enforce_keys [:type, :interval]
  defstruct type:     nil,
            interval: nil

  @spec new(Cocktail.frequency, pos_integer) :: t
  def new(type, interval), do: %__MODULE__{type: type, interval: interval}

  @spec next_time(t, Cocktail.time, Cocktail.time) :: Cocktail.Validation.Shift.result
  def next_time(%__MODULE__{type: :weekly, interval: interval}, time, start_time), do: apply_interval(time, start_time, interval, :weeks)
  def next_time(%__MODULE__{type: :daily, interval: interval}, time, start_time), do: apply_interval(time, start_time, interval, :days)
  def next_time(%__MODULE__{type: :hourly, interval: interval}, time, start_time), do: apply_interval(time, start_time, interval, :hours)
  def next_time(%__MODULE__{type: :minutely, interval: interval}, time, start_time), do: apply_interval(time, start_time, interval, :minutes)
  def next_time(%__MODULE__{type: :secondly, interval: interval}, time, start_time), do: apply_interval(time, start_time, interval, :seconds)

  @spec apply_interval(Cocktail.time, Cocktail.time, pos_integer, interval_shift_type) :: Cocktail.Validation.Shift.result
  defp apply_interval(time, _, 1, _), do: {:no_change, time}
  defp apply_interval(time, start_time, interval, :weeks), do: apply_interval(time, start_time, interval * 7, :days)
  defp apply_interval(time, start_time, interval, :days) do
    date = Timex.to_date(time)
    start_date = Timex.to_date(start_time)

    start_date
    |> Timex.diff(date, :days)
    |> mod(interval)
    |> shift_by(:days, time)
  end
  defp apply_interval(time, start_time, interval, type) do
    start_time
    |> Timex.diff(time, type)
    |> mod(interval)
    |> shift_by(type, time)
  end
end
