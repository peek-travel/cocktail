defmodule Cocktail.Validation.ScheduleLock do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type lock :: :second | :minute | :hour | :wday | :mday

  @type t :: %__MODULE__{type: lock}

  @enforce_keys [:type]
  defstruct type: nil

  @spec new(lock) :: t
  def new(type), do: %__MODULE__{type: type}

  @spec next_time(t, Cocktail.time(), Cocktail.time()) :: Cocktail.Validation.Shift.result()
  def next_time(%__MODULE__{type: :second}, time, start_time),
    do: shift_by(mod(start_time.second - time.second, 60), :seconds, time)

  def next_time(%__MODULE__{type: :minute}, time, start_time),
    do: shift_by(mod(start_time.minute - time.minute, 60), :minutes, time)

  def next_time(%__MODULE__{type: :hour}, time, start_time),
    do: shift_by(mod(start_time.hour - time.hour, 24), :hours, time)

  def next_time(%__MODULE__{type: :wday}, time, start_time) do
    start_time_day = Timex.weekday(start_time)
    time_day = Timex.weekday(time)
    diff = mod(start_time_day - time_day, 7)

    shift_by(diff, :days, time)
  end

  def next_time(%__MODULE__{type: :mday}, time, start_time) do
    start_time_day_of_month = start_time.day
    time_day_of_month = time.day

    # no day shift when there is day of month difference
    day_diff =
      if start_time_day_of_month == time_day_of_month do
        0
      else
        # We have to shift to the same day of month of start_time in next month
        if time_day_of_month > start_time_day_of_month do
          next_month_date = Timex.shift(time, months: 1)
          # Timex.set already handle the marginal case like setting a day of month more than the month contains
          next_month_date
          |> Timex.set(day: start_time_day_of_month)
          |> Timex.diff(time, :days)
        else
          time
          |> Timex.set(day: start_time_day_of_month)
          |> Timex.diff(time, :days)
        end
      end

    shift_by(day_diff, :days, time)
  end
end
