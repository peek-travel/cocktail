defmodule Cocktail.Validation.ScheduleLock do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift

  @type lock :: :second | :minute | :hour | :wday

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
end
