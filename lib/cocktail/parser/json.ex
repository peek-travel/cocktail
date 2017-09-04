defmodule Cocktail.Parser.JSON do
  @moduledoc """
  TODO: write module doc
  """

  alias Cocktail.{Schedule, Rule}

  @doc ~S"""
  Parses the given `json_string` into a `t:Cocktail.Schedule.t/0`.

  ## Examples

      iex> {:ok, schedule} = parse("{\"start_time\":{\"time\":\"2017-01-01 09:00:00\",\"zone\":\"America/Los_Angeles\"},\"recurrence_rules\":[{\"frequency\":\"daily\",\"interval\":2}]}")
      ...> schedule
      #Cocktail.Schedule<Every 2 days>
  """
  def parse(json_string) when is_binary(json_string) do
    with {:ok, config} <- Poison.decode(json_string)
    do
      parse_map(config)
    else
      error -> {:error, {:invalid_json, error}}
    end
  end

  @doc """
  Parses the given `map` into a `t:Cocktail.Schedule.t/0`.

  ## Examples

      iex> {:ok, schedule} = parse_map(%{"start_time"=>%{"time"=>"2017-01-01 09:00:00","zone"=>"America/Los_Angeles"},"recurrence_rules"=>[%{"frequency"=>"daily","interval"=>2}]})
      ...> schedule
      #Cocktail.Schedule<Every 2 days>
  """
  def parse_map(%{"start_time" => start_time} = map) do
    with {:ok, time}     <- parse_time(start_time),
         {:ok, rules}    <- parse_rules(map["recurrence_rules"]),
         {:ok, schedule} <- create_schedule(time, map["duration"])
    do
      {:ok, Enum.reduce(rules |> Enum.reverse, schedule, &add_recurrence_rule/2)}
    end
  end
  def parse_map(map) when is_map(map), do: {:error, :missing_start_time}

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
  # TODO: support a pre-parsed DateTime object being passed
  defp parse_time(nil), do: {:error, :missing_start_time}
  defp parse_time(_), do: {:error, :invalid_time_format}

  defp parse_rules(rule_configs, rules \\ [], index \\ 0)
  defp parse_rules(nil, rules, _), do: {:ok, rules}
  defp parse_rules([], rules, _), do: {:ok, rules}
  defp parse_rules([rule_config | rest], rules, index) when is_map(rule_config) do
    with {:ok, options} <- validate_rule_options(rule_config, index)
    do
      rule = Rule.new(options)
      parse_rules(rest, [rule | rules], index + 1)
    end
  end
  defp parse_rules(_, _, index), do: {:error, {:invalid_rule, index}}

  defp create_schedule(time, nil), do: {:ok, Schedule.new(time)}
  defp create_schedule(time, duration) when is_integer(duration) and duration > 0, do: {:ok, Schedule.new(time, duration: duration)}
  defp create_schedule(_, _), do: {:error, :invalid_duration}

  defp validate_rule_options(options, index) when is_map(options) do
    with {:ok, frequency} <- parse_frequency(options, index),
         {:ok, interval}  <- parse_interval(options, index),
         {:ok, until}     <- parse_until(options, index),
         {:ok, days}      <- parse_days(options, index),
         {:ok, hours}     <- parse_hours(options, index)
    do
      {:ok, [
        frequency: frequency,
        interval: interval,
        until: until,
        days: days,
        hours: hours
      ] |> Enum.reject(fn({_, x}) -> is_nil(x) end)}
    end
  end

  defp parse_frequency(%{"frequency" => "secondly"}, _), do: {:ok, :secondly}
  defp parse_frequency(%{"frequency" => "minutely"}, _), do: {:ok, :minutely}
  defp parse_frequency(%{"frequency" => "hourly"}, _), do: {:ok, :hourly}
  defp parse_frequency(%{"frequency" => "daily"}, _), do: {:ok, :daily}
  defp parse_frequency(%{"frequency" => "weekly"}, _), do: {:ok, :weekly}
  defp parse_frequency(%{"frequency" => "monthly"}, _), do: {:ok, :monthly}
  defp parse_frequency(%{"frequency" => "yearly"}, _), do: {:ok, :yearly}
  defp parse_frequency(%{"frequency" => _}, index), do: {:error, {:invalid_frequency, index}}
  defp parse_frequency(_, index), do: {:error, {:missing_frequency, index}}

  defp parse_interval(%{"interval" => interval}, _) when is_integer(interval) and interval > 0, do: {:ok, interval}
  defp parse_interval(_, index), do: {:error, {:invalid_interval, index}}

  defp parse_until(%{"until" => until}, index) do
    case parse_time(until) do
      {:ok, time} ->
        {:ok, time}
      {:error, term} ->
        {:error, {term, index}}
    end
  end
  defp parse_until(_, _), do: {:ok, nil}

  # TODO: parse count

  defp parse_days(%{"days" => []}, _), do: {:ok, nil}
  defp parse_days(%{"days" => days}, index) when is_list(days), do: do_parse_days(days, [], index)
  defp parse_days(%{"days" => nil}, _), do: {:ok, nil}
  defp parse_days(%{"days" => _}, index), do: {:error, {:invalid_days, index}}
  defp parse_days(_, _), do: {:ok, nil}

  defp do_parse_days([], days, _), do: {:ok, days |> Enum.reverse}
  defp do_parse_days([day | rest], days, index) do
    with {:ok, day} <- parse_day(day, index), do: do_parse_days(rest, [day | days], index)
  end

  defp parse_day("monday", _), do: {:ok, :monday}
  defp parse_day("tuesday", _), do: {:ok, :tuesday}
  defp parse_day("wednesday", _), do: {:ok, :wednesday}
  defp parse_day("thursday", _), do: {:ok, :thursday}
  defp parse_day("friday", _), do: {:ok, :friday}
  defp parse_day("saturday", _), do: {:ok, :saturday}
  defp parse_day("sunday", _), do: {:ok, :sunday}
  # TODO: support parsing days as integers
  defp parse_day(_, index), do: {:error, {:invalid_day, index}}

  defp parse_hours(%{"hours" => []}, _), do: {:ok, nil}
  defp parse_hours(%{"hours" => hours}, index) when is_list(hours), do: do_parse_hours(hours, [], index)
  defp parse_hours(%{"hours" => nil}, _), do: {:ok, nil}
  defp parse_hours(%{"hours" => _}, index), do: {:error, {:invalid_hours, index}}
  defp parse_hours(_, _), do: {:ok, nil}

  defp do_parse_hours([], hours, _), do: {:ok, hours |> Enum.reverse}
  defp do_parse_hours([day | rest], hours, index) do
    with {:ok, day} <- parse_hour(day, index), do: do_parse_hours(rest, [day | hours], index)
  end

  defp parse_hour(hour, _) when is_integer(hour) and hour >= 0 and hour < 24, do: {:ok, hour}
  defp parse_hour(_, index), do: {:error, {:invalid_hour, index}}
end
