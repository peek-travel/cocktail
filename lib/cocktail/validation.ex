defmodule Cocktail.Validation do
  alias Cocktail.Validation.{Interval, ScheduleLock}

  def next_time(%Interval{} = validation, time, start_time), do: Interval.next_time(validation, time, start_time)
  def next_time(%ScheduleLock{} = validation, time, start_time), do: ScheduleLock.next_time(validation, time, start_time)
end
