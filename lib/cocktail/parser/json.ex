defmodule Cocktail.Parser.JSON do
  alias Cocktail.{Schedule, Rule}

  def parse(text) when is_binary(text) do
    with {:ok, config} <- Poison.decode(text), do: parse(config)
  end
  def parse(%{"start_time" => start_time} = config) do
    with {:ok, time}     <- parse_time(start_time),
         {:ok, rules}    <- parse_rules(config["recurrence_rules"]),
         {:ok, schedule} <- create_schedule(time, config["duration"])
    do
      {:ok, Enum.reduce(rules |> Enum.reverse, schedule, &add_recurrence_rule/2)}
    end
  end
  def parse(config) when is_map(config), do: {:errors, :missing_start_time}

  defp add_recurrence_rule(rule, schedule), do: Schedule.add_recurrence_rule(schedule, rule)

  defp parse_time(%{"time" => time_string, "zone" => zone_id}) do
    with {:ok, time}         <- Timex.parse(time_string, "{ISO:Extended}"),
         %DateTime{} = time  <- Timex.to_datetime(time, zone_id)
    do
      {:ok, time}
    else
      _ ->
        {:error, :invalid_time_format}
    end
  end
  defp parse_time(_), do: {:error, :invalid_time_format}

  defp parse_rules(rule_configs, rules \\ [])
  defp parse_rules(nil, rules), do: {:ok, rules}
  defp parse_rules([], rules), do: {:ok, rules}
  defp parse_rules([rule_config | rest], rules) do
    with {:ok, options}   <- validate_rule_options(rule_config),
         {:ok, frequency} <- Keyword.fetch(options, :frequency),
         {:ok, rule}      <- create_rule(frequency, options)
    do
      parse_rules(rest, [rule | rules])
    end
  end

  defp create_rule(frequency, options) do
    case Rule.new(frequency, options) do
      %Rule{} = rule ->
        {:ok, rule}
      _ ->
        {:error, :invalid_rule}
    end
  end

  defp create_schedule(time, nil), do: {:ok, Schedule.new(time)}
  defp create_schedule(time, duration) when is_integer(duration) and duration > 0, do: {:ok, Schedule.new(time, duration: duration)}
  defp create_schedule(_, _), do: {:error, :invalid_duration}

  defp validate_rule_options(options) when is_map(options) do
    with {:ok, frequency} <- parse_frequency(options),
         {:ok, interval}  <- parse_interval(options),
         {:ok, until}     <- parse_until(options),
         {:ok, days}      <- parse_days(options),
         {:ok, hours}     <- parse_hours(options)
    do
      {:ok, [
        frequency: frequency,
        interval: interval,
        until: until,
        days: days,
        hours: hours
      ]}
    end
  end
  defp validate_rule_options(_), do: {:error, :invalid_rule_options}

  defp parse_frequency(%{"frequency" => "secondly"}), do: {:ok, :secondly}
  defp parse_frequency(%{"frequency" => "minutely"}), do: {:ok, :minutely}
  defp parse_frequency(%{"frequency" => "hourly"}), do: {:ok, :hourly}
  defp parse_frequency(%{"frequency" => "daily"}), do: {:ok, :daily}
  defp parse_frequency(%{"frequency" => "weekly"}), do: {:ok, :weekly}
  defp parse_frequency(%{"frequency" => "monthly"}), do: {:ok, :monthly}
  defp parse_frequency(%{"frequency" => "yearly"}), do: {:ok, :yearly}
  defp parse_frequency(_), do: {:error, :invalid_frequency}

  defp parse_interval(%{"interval" => interval}) when is_integer(interval) and interval > 0, do: {:ok, interval}
  defp parse_interval(_), do: {:error, :invalid_interval}

  defp parse_until(%{"until" => until}), do: parse_time(until)
  defp parse_until(_), do: {:ok, nil}

  defp parse_days(%{"days" => days}) when is_list(days), do: do_parse_days(days, [])
  defp parse_days(%{"days" => nil}), do: {:ok, nil}
  defp parse_days(%{"days" => _}), do: {:error, :invalid_days}
  defp parse_days(_), do: {:ok, nil}

  defp do_parse_days([], days), do: {:ok, days |> Enum.reverse}
  defp do_parse_days([day | rest], days) do
    with {:ok, day} <- parse_day(day), do: do_parse_days(rest, [day | days])
  end

  defp parse_day("monday"), do: {:ok, :monday}
  defp parse_day("tuesday"), do: {:ok, :tuesday}
  defp parse_day("wednesday"), do: {:ok, :wednesday}
  defp parse_day("thursday"), do: {:ok, :thursday}
  defp parse_day("friday"), do: {:ok, :friday}
  defp parse_day("saturday"), do: {:ok, :saturday}
  defp parse_day("sunday"), do: {:ok, :sunday}
  defp parse_day(_), do: {:error, :invalid_day}

  defp parse_hours(%{"hours" => hours}) when is_list(hours), do: do_parse_hours(hours, [])
  defp parse_hours(%{"hours" => nil}), do: {:ok, nil}
  defp parse_hours(%{"hours" => _}), do: {:error, :invalid_hours}
  defp parse_hours(_), do: {:ok, nil}

  defp do_parse_hours([], hours), do: {:ok, hours |> Enum.reverse}
  defp do_parse_hours([day | rest], hours) do
    with {:ok, day} <- parse_hour(day), do: do_parse_hours(rest, [day | hours])
  end

  defp parse_hour(hour) when is_integer(hour) and hour >= 0, do: {:ok, hour}
  defp parse_hour(_), do: {:error, :invalid_hour}
end
