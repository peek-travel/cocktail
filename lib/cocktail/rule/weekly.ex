defmodule Cocktail.Rule.Weekly do
  alias Cocktail.Validation.{Interval, ScheduleLock, Day, HourOfDay}

  def build_validations(options) do
    interval = Keyword.get(options, :interval, 1)
    days = Keyword.get(options, :days)
    hours = Keyword.get(options, :hours)

    do_build_validations(interval, hours, days)
  end

  defp do_build_validations(interval, nil, nil) do
    base_validations() ++ [ base_wday: [ ScheduleLock.new(:wday) ] ] ++ interval_validation(interval)
  end

  defp do_build_validations(interval, nil, days) do
    base_validations() ++ [ day: day_validations(days) ] ++ interval_validation(interval)
  end

  defp do_build_validations(interval, hours, nil) do
    base_validations_without_hour() ++ [ hour_of_day: hour_validations(hours), base_wday: [ ScheduleLock.new(:wday) ] ] ++ interval_validation(interval)
  end

  defp do_build_validations(interval, hours, days) do
    base_validations_without_hour() ++ [ hour_of_day: hour_validations(hours), day: day_validations(days) ] ++ interval_validation(interval)
  end

  defp base_validations do
    [
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ],
      base_hour: [ ScheduleLock.new(:hour) ]
    ]
  end

  defp base_validations_without_hour do
    [
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ]
    ]
  end

  defp interval_validation(interval) do
    [
      interval: [ Interval.new(:weekly, interval) ]
    ]
  end

  defp day_validations(days), do: days |> Enum.map(&Day.new/1)
  defp hour_validations(hours), do: hours |> Enum.map(&HourOfDay.new/1)
end
