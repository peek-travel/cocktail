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
    do: shift_by(mod(start_time.second - time.second, 60), :second, time)

  def next_time(%__MODULE__{type: :minute}, time, start_time),
    do: shift_by(mod(start_time.minute - time.minute, 60), :minute, time)

  def next_time(%__MODULE__{type: :hour}, time, start_time),
    do: shift_by(mod(start_time.hour - time.hour, 24), :hour, time)

  def next_time(%__MODULE__{type: :wday}, time, start_time) do
    {start_time_day, _, _} = Calendar.ISO.day_of_week(start_time.year, start_time.month, start_time.day, :sunday)
    start_time_day = start_time_day - 1

    {time_day, _, _} = Calendar.ISO.day_of_week(time.year, time.month, time.day, :sunday)
    time_day = time_day - 1
    diff = mod(start_time_day - time_day, 7)

    shift_by(diff, :day, time)
  end

  def next_time(%__MODULE__{type: :mday}, time, start_time) do
    if start_time.day > Calendar.ISO.days_in_month(time.year, time.month) do
      next_time(%__MODULE__{type: :mday}, Cocktail.Time.shift(time, 1, :month), start_time)
    else
      next_mday_time(%__MODULE__{type: :mday}, time, start_time)
    end
  end

  defp next_mday_time(%__MODULE__{type: :mday}, time, start_time) do
    time_day_of_month = time.day

    day_diff =
      case start_time.day do
        # no day shift when there is day of month difference
        ^time_day_of_month ->
          0

        # We to the same day of month of start_time in next month if the days of month are not equal
        start_time_day_of_month when start_time_day_of_month > time_day_of_month ->
          time
          |> Map.put(:day, start_time_day_of_month)
          |> Cocktail.Time.diff(time, :day)

        start_time_day_of_month ->
          time
          |> Cocktail.Time.shift(1, :month)
          |> Map.put(:day, start_time_day_of_month)
          |> Cocktail.Time.diff(time, :day)
      end

    shift_by(day_diff, :day, time)
  end
end
