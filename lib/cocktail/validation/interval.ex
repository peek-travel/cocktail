defmodule Cocktail.Validation.Interval do
  @moduledoc false

  import Integer, only: [mod: 2, floor_div: 2]
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
  defp apply_interval(time, start_time, interval, :weeks) do
    week = Timex.iso_week(time)
    start_week = Timex.iso_week(start_time)
    diff = weeks_diff(start_week, week)
    off_by = mod(diff * -1, interval)
    shift_by(off_by * 7, :days, time)
  end
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

  defp weeks_diff({year, week1}, {year, week2}), do: week2 - week1
  defp weeks_diff({year1, week1}, {year2, week2}) do
    (year1..(year2 - 1) |> Enum.map(&iso_weeks_per_year/1) |> Enum.sum) - week1 + week2
  end

  defp iso_weeks_per_year(year) do
    if year_cycle(year) == 4 || year_cycle(year - 1) == 3 do
      53
    else
      52
    end
  end

  defp year_cycle(year) do
    year + floor_div(year, 4) - floor_div(year, 100) + floor_div(year, 400) |> mod(7)
  end
end
