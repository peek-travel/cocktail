defmodule Cocktail.Validation.Lock do
  import Integer, only: [mod: 2]
  import Timex, only: [shift: 2]

  def lock_seconds(time, start_time), do: time |> shift(seconds: mod(start_time.second - time.second, 60))
  def lock_minutes(time, start_time), do: time |> shift(minutes: mod(start_time.minute - time.minute, 60))
  def lock_hours(time, start_time), do: time |> shift(hours: mod(start_time.hour - time.hour, 24))
end
