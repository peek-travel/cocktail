defmodule Cocktail.Validation do
  @moduledoc false

  alias Cocktail.Validation.{ScheduleLock, Interval, Day, HourOfDay}

  @type t :: ScheduleLock.t | Interval.t | Day.t | HourOfDay.t

  def build_validations(options) do
    {frequency, options} = Keyword.pop(options, :frequency)
    {interval, options} = Keyword.pop(options, :interval, 1)

    build_basic_interval_validations(frequency, interval) |> apply_options(options)
  end

  defp build_basic_interval_validations(:weekly, interval) do
    %{
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ],
      base_hour: [ ScheduleLock.new(:hour) ],
      base_wday: [ ScheduleLock.new(:wday) ],
      interval: [ Interval.new(:weekly, interval) ]
    }
  end

  defp build_basic_interval_validations(:daily, interval) do
    %{
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ],
      base_hour: [ ScheduleLock.new(:hour) ],
      interval: [ Interval.new(:daily, interval) ]
    }
  end

  defp build_basic_interval_validations(:hourly, interval) do
    %{
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ],
      interval: [ Interval.new(:hourly, interval) ]
    }
  end

  defp build_basic_interval_validations(:minutely, interval) do
    %{
      base_sec: [ ScheduleLock.new(:second) ],
      interval: [ Interval.new(:minutely, interval) ]
    }
  end

  defp build_basic_interval_validations(:secondly, interval) do
    %{
      interval: [ Interval.new(:secondly, interval) ]
    }
  end

  defp apply_options(map, []), do: map
  defp apply_options(map, [{:days, days} | rest]) do
    map
    |> Map.delete(:base_wday)
    |> Map.put(:day, day_validations(days))
    |> apply_options(rest)
  end
  defp apply_options(map, [{:hours, hours} | rest]) do
    map
    |> Map.delete(:base_hour)
    |> Map.put(:hour_of_day, hour_validations(hours))
    |> apply_options(rest)
  end
  defp apply_options(map, [{_, _} | rest]), do: map |> apply_options(rest) # unhandled option, just discard and continue

  defp day_validations(days), do: days |> Enum.map(&Day.new/1)

  defp hour_validations(hours), do: hours |> Enum.map(&HourOfDay.new/1)
end
