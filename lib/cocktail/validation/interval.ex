defmodule Cocktail.Validation.Interval do
  @moduledoc false

  import Integer, only: [mod: 2, floor_div: 2]
  import Cocktail.Validation.Shift

  @typep iso_week :: {Timex.Types.year(), Timex.Types.weeknum()}

  @type t :: %__MODULE__{type: Cocktail.frequency(), interval: pos_integer}

  @enforce_keys [:type, :interval]
  defstruct type: nil,
            interval: nil

  @spec new(Cocktail.frequency(), pos_integer) :: t
  def new(type, interval), do: %__MODULE__{type: type, interval: interval}

  @spec next_time(t, Cocktail.time(), Cocktail.time()) :: Cocktail.Validation.Shift.result()
  def next_time(%__MODULE__{type: _, interval: 1}, time, _), do: {:no_change, time}

  def next_time(%__MODULE__{type: :monthly, interval: interval}, time, start_time) do
    start_time
    |> Timex.beginning_of_month()
    |> Timex.diff(Timex.beginning_of_month(time), :months)
    |> mod(interval)
    |> shift_by(:months, time)
  end

  def next_time(%__MODULE__{type: :weekly, interval: interval}, time, start_time) do
    week = Timex.iso_week(time)
    start_week = Timex.iso_week(start_time)
    diff = weeks_diff(start_week, week)
    off_by = mod(diff * -1, interval)
    shift_by(off_by * 7, :days, time)
  end

  def next_time(%__MODULE__{type: :daily, interval: interval}, time, start_time) do
    date = Timex.to_date(time)
    start_date = Timex.to_date(start_time)

    start_date
    |> Timex.diff(date, :days)
    |> mod(interval)
    |> shift_by(:days, time)
  end

  def next_time(%__MODULE__{type: type, interval: interval}, time, start_time) do
    unit = unit_for_type(type)

    start_time
    |> Timex.diff(time, unit)
    |> mod(interval)
    |> shift_by(unit, time)
  end

  @spec weeks_diff(iso_week, iso_week) :: integer
  defp weeks_diff({year, week1}, {year, week2}) when week2 >= week1, do: week2 - week1

  defp weeks_diff({year1, week1}, {year2, week2}) when year2 > year1,
    do: (year1..(year2 - 1) |> Enum.map(&iso_weeks_per_year/1) |> Enum.sum()) - week1 + week2

  @spec iso_weeks_per_year(Timex.Types.year()) :: 52 | 53
  defp iso_weeks_per_year(year) do
    if year_cycle(year) == 4 || year_cycle(year - 1) == 3 do
      53
    else
      52
    end
  end

  @spec year_cycle(Timex.Types.year()) :: integer
  defp year_cycle(year) do
    cycle = year + floor_div(year, 4) - floor_div(year, 100) + floor_div(year, 400)

    mod(cycle, 7)
  end

  @spec unit_for_type(:hourly | :minutely | :secondly) :: :hours | :minutes | :seconds
  defp unit_for_type(:hourly), do: :hours
  defp unit_for_type(:minutely), do: :minutes
  defp unit_for_type(:secondly), do: :seconds
end
