defmodule Cocktail.Rule.Weekly do
  alias Cocktail.Validation.{Interval, ScheduleLock, Day}

  def build_validations(options) do
    interval = Keyword.get(options, :interval, 1)
    days = Keyword.get(options, :days)

    do_build_validations(interval, days)
  end

  defp do_build_validations(interval, nil) do
    base_validations() ++ [ base_wday: [ ScheduleLock.new(:wday) ] ] ++ interval_validation(interval)
  end

  defp do_build_validations(interval, days) do
    base_validations() ++ [ day: day_validations(days) ] ++ interval_validation(interval)
  end

  defp base_validations do
    [
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ],
      base_hour: [ ScheduleLock.new(:hour) ]
    ]
  end

  defp interval_validation(interval) do
    [
      interval: [ Interval.new(:weekly, interval) ]
    ]
  end

  defp day_validations(days), do: days |> Enum.map(&Day.new/1)
end
