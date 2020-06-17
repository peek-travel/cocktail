defmodule Cocktail.Validation.DayOfMonth do
  @moduledoc false

  import Cocktail.Validation.Shift
  import Cocktail.Util, only: [next_gte: 2]

  @type t :: %__MODULE__{days: [Cocktail.day_of_month()]}

  @enforce_keys [:days]
  defstruct days: []

  @spec new([Cocktail.day()]) :: t
  def new(days), do: %__MODULE__{days: days}

  @spec next_time(t, Cocktail.time(), Cocktail.time()) :: Cocktail.Validation.Shift.result()
  def next_time(%__MODULE__{days: days}, time, _) do
    current_day_of_month = time.day
    normailized_days = Enum.map(days, &normalize_day_of_month(&1, time))

    diff =
      case next_gte(normailized_days, current_day_of_month) do
        # go to next month
        nil ->
          next_month_time =
            time
            |> Timex.shift(months: 1)

          next_month_normailized_days = Enum.map(days, &normalize_day_of_month(&1, next_month_time))

          next_month_time
          |> Timex.set(day: hd(Enum.sort(next_month_normailized_days)))
          |> Timex.diff(time, :days)

        next_earliest_day_of_month ->
          next_earliest_day_of_month - current_day_of_month
      end

    shift_by(diff, :days, time, :beginning_of_day)
  end

  defp normalize_day_of_month(day_of_month, current_time) do
    do_normalize_day_of_month(day_of_month, Timex.days_in_month(current_time))
  end

  defp do_normalize_day_of_month(day_of_month, days_in_month) when day_of_month > days_in_month do
    days_in_month
  end

  defp do_normalize_day_of_month(day_of_month, _days_in_month) when day_of_month > 0 do
    day_of_month
  end

  defp do_normalize_day_of_month(day_of_month, days_in_month) when -day_of_month > days_in_month do
    1
  end

  defp do_normalize_day_of_month(day_of_month, days_in_month) when day_of_month < 0 do
    days_in_month + day_of_month
  end
end
