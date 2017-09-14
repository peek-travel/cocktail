defmodule Cocktail.Validation do
  @moduledoc false

  alias Cocktail.Validation.{ScheduleLock, Interval, Day, HourOfDay, MinuteOfHour, SecondOfMinute}

  @type validation_key :: :base_sec         |
                          :base_min         |
                          :base_hour        |
                          :base_wday        |
                          :day              |
                          :hour_of_day      |
                          :minute_of_hour   |
                          :second_of_minute |
                          :interval

  @type validations_map :: %{validation_key => [t]}

  @type t :: ScheduleLock.t | Interval.t | Day.t | HourOfDay.t | MinuteOfHour.t | SecondOfMinute.t

  @spec build_validations(Cocktail.rule_options) :: validations_map
  def build_validations(options) do
    {frequency, options} = Keyword.pop(options, :frequency)
    {interval, options} = Keyword.pop(options, :interval, 1)

    frequency
    |> build_basic_interval_validations(interval)
    |> apply_options(options)
  end

  @spec build_basic_interval_validations(Cocktail.frequency, pos_integer) :: validations_map
  defp build_basic_interval_validations(:weekly, interval) do
    %{
      base_sec: [ScheduleLock.new(:second)],
      base_min: [ScheduleLock.new(:minute)],
      base_hour: [ScheduleLock.new(:hour)],
      base_wday: [ScheduleLock.new(:wday)],
      interval: [Interval.new(:weekly, interval)]
    }
  end
  defp build_basic_interval_validations(:daily, interval) do
    %{
      base_sec: [ScheduleLock.new(:second)],
      base_min: [ScheduleLock.new(:minute)],
      base_hour: [ScheduleLock.new(:hour)],
      interval: [Interval.new(:daily, interval)]
    }
  end
  defp build_basic_interval_validations(:hourly, interval) do
    %{
      base_sec: [ScheduleLock.new(:second)],
      base_min: [ScheduleLock.new(:minute)],
      interval: [Interval.new(:hourly, interval)]
    }
  end
  defp build_basic_interval_validations(:minutely, interval) do
    %{
      base_sec: [ScheduleLock.new(:second)],
      interval: [Interval.new(:minutely, interval)]
    }
  end
  defp build_basic_interval_validations(:secondly, interval) do
    %{
      interval: [Interval.new(:secondly, interval)]
    }
  end

  @spec apply_options(validations_map, Cocktail.rule_options) :: validations_map
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
  defp apply_options(map, [{:minutes, minutes} | rest]) do
    map
    |> Map.delete(:base_min)
    |> Map.put(:minute_of_hour, minute_validations(minutes))
    |> apply_options(rest)
  end
  defp apply_options(map, [{:seconds, seconds} | rest]) do
    map
    |> Map.delete(:base_sec)
    |> Map.put(:second_of_minute, second_validations(seconds))
    |> apply_options(rest)
  end
  defp apply_options(map, [{_, _} | rest]), do: map |> apply_options(rest) # unhandled option, just discard and continue

  @spec day_validations([Cocktail.day_number]) :: [Day.t]
  defp day_validations(days), do: days |> Enum.map(&Day.new/1)

  @spec hour_validations([Cocktail.hour_number]) :: [HourOfDay.t]
  defp hour_validations(hours), do: hours |> Enum.map(&HourOfDay.new/1)

  @spec minute_validations([Cocktail.minute_number]) :: [MinuteOfHour.t]
  defp minute_validations(minutes), do: minutes |> Enum.map(&MinuteOfHour.new/1)

  @spec second_validations([Cocktail.second_number]) :: [SecondOfMinute.t]
  defp second_validations(seconds), do: seconds |> Enum.map(&SecondOfMinute.new/1)
end
