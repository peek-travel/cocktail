defmodule Cocktail.Parser.JSON do
  @moduledoc """
  Create schedules from JSON strings or maps.

  TODO: write long description
  """

  alias Cocktail.{Schedule, Rule}

  @doc ~S"""
  Parses a string of JSON into a `t:Cocktail.Schedule.t/0`.

  ## Examples

      iex> {:ok, schedule} = parse("{\"start_time\":\"2017-01-01 09:00:00\",\"recurrence_rules\":[{\"frequency\":\"daily\",\"interval\":2}]}")
      ...> schedule
      #Cocktail.Schedule<Every 2 days>
  """
  @spec parse(String.t) :: {:ok, Schedule.t} | {:error, term}
  def parse(json_string) when is_binary(json_string) do
    with {:ok, config} <- Poison.decode(json_string)
    do
      parse_map(config)
    else
      error -> {:error, {:invalid_json, error}}
    end
  end

  @doc """
  Parses JSON-like map into a `t:Cocktail.Schedule.t/0`.

  ## Examples

      iex> {:ok, schedule} = parse_map(%{"start_time"=>"2017-01-01 09:00:00","recurrence_rules"=>[%{"frequency"=>"daily","interval"=>2}]})
      ...> schedule
      #Cocktail.Schedule<Every 2 days>
  """
  @spec parse_map(map) :: {:ok, Schedule.t} | {:error, term}
  def parse_map(%{"start_time" => start_time} = map) do
    with {:ok, time}     <- parse_time(start_time),
         {:ok, rules}    <- parse_rules(map["recurrence_rules"]),
         {:ok, schedule} <- create_schedule(time, map["duration"])
    do
      {:ok, Enum.reduce(rules |> Enum.reverse, schedule, &Schedule.add_recurrence_rule(&2, &1))}
    end
  end
  def parse_map(map) when is_map(map), do: {:error, :missing_start_time}

  @spec parse_time(map | String.t | nil) :: {:ok, Cocktail.time} | {:error, term}
  defp parse_time(%{"time" => time_string, "zone" => zone_id}) do
    with {:ok, time}         <- Timex.parse(time_string, "{ISO:Extended}"),
         %DateTime{} = time  <- Timex.to_datetime(time, zone_id)
    do
      {:ok, time}
    else
      _ -> {:error, :invalid_time_format}
    end
  end
  defp parse_time(time_string) when is_binary(time_string) do
    with {:ok, time} <- Timex.parse(time_string, "{ISO:Extended}")
    do
      {:ok, time}
    else
      _ -> {:error, :invalid_time_format}
    end
  end
  # TODO: support a pre-parsed DateTime or NaiveDateTime object being passed
  defp parse_time(_), do: {:error, :invalid_time_format}

  @spec parse_rules([map] | nil, [Rule.t]) :: {:ok, [Rule.t]} | {:error, term}
  defp parse_rules(rule_configs, rules \\ [], index \\ 0)
  defp parse_rules(nil, rules, _), do: {:ok, rules}
  defp parse_rules([], rules, _), do: {:ok, rules}
  defp parse_rules([rule_config | rest], rules, index) when is_map(rule_config) do
    with {:ok, options} <- parse_rule_options(rule_config)
    do
      rule = Rule.new(options)
      parse_rules(rest, [rule | rules], index + 1)
    else
      {:error, term} -> {:error, {term, index}}
    end
  end
  defp parse_rules(_, _, index), do: {:error, {:invalid_rule, index}}

  @spec create_schedule(Cocktail.time, pos_integer | nil) :: {:ok, Schedule.t} | {:error, term}
  defp create_schedule(time, nil), do: {:ok, Schedule.new(time)}
  defp create_schedule(time, duration) when is_integer(duration) and duration > 0, do: {:ok, Schedule.new(time, duration: duration)}
  defp create_schedule(_, _), do: {:error, :invalid_duration}

  @spec parse_rule_options(map) :: {:ok, Cocktail.rule_options} | {:error, term}
  defp parse_rule_options(options) when is_map(options) do
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
      ] |> Enum.reject(fn({_, x}) -> is_nil(x) end)}
    end
  end

  @spec parse_frequency(map) :: {:ok, Cocktail.frequency} | {:error, term}
  defp parse_frequency(%{"frequency" => "secondly"}), do: {:ok, :secondly}
  defp parse_frequency(%{"frequency" => "minutely"}), do: {:ok, :minutely}
  defp parse_frequency(%{"frequency" => "hourly"}), do: {:ok, :hourly}
  defp parse_frequency(%{"frequency" => "daily"}), do: {:ok, :daily}
  defp parse_frequency(%{"frequency" => "weekly"}), do: {:ok, :weekly}
  defp parse_frequency(%{"frequency" => "monthly"}), do: {:ok, :monthly}
  defp parse_frequency(%{"frequency" => "yearly"}), do: {:ok, :yearly}
  defp parse_frequency(%{"frequency" => _}), do: {:error, :invalid_frequency}
  defp parse_frequency(_), do: {:error, :missing_frequency}

  @spec parse_interval(map) :: {:ok, pos_integer} | {:error, :invalid_interval}
  defp parse_interval(%{"interval" => interval}) when is_integer(interval) and interval > 0, do: {:ok, interval}
  defp parse_interval(_), do: {:error, :invalid_interval}

  @spec parse_until(map) :: {:ok, Cocktail.time | nil} | {:error, term}
  defp parse_until(%{"until" => until}), do: parse_time(until)
  defp parse_until(_), do: {:ok, nil}

  # TODO: parse count

  @spec parse_days(map) :: {:ok, [Cocktail.day_atom] | nil} | {:error, term}
  defp parse_days(%{"days" => []}), do: {:ok, nil}
  defp parse_days(%{"days" => days}) when is_list(days), do: do_parse_days(days, [])
  defp parse_days(%{"days" => nil}), do: {:ok, nil}
  defp parse_days(%{"days" => _}), do: {:error, :invalid_days}
  defp parse_days(_), do: {:ok, nil}

  @spec do_parse_days([String.t], [Cocktail.day_atom]) :: {:ok, [Cocktail.day_atom]} | {:error, :invalid_day}
  defp do_parse_days([], days), do: {:ok, days |> Enum.reverse}
  defp do_parse_days([day | rest], days) do
    with {:ok, day} <- parse_day(day), do: do_parse_days(rest, [day | days])
  end

  @spec parse_day(String.t) :: {:ok, Cocktail.day_atom} | {:error, :invalid_day}
  defp parse_day("monday"), do: {:ok, :monday}
  defp parse_day("tuesday"), do: {:ok, :tuesday}
  defp parse_day("wednesday"), do: {:ok, :wednesday}
  defp parse_day("thursday"), do: {:ok, :thursday}
  defp parse_day("friday"), do: {:ok, :friday}
  defp parse_day("saturday"), do: {:ok, :saturday}
  defp parse_day("sunday"), do: {:ok, :sunday}
  # TODO: support parsing days as integers
  defp parse_day(_), do: {:error, :invalid_day}

  @spec parse_hours(map) :: {:ok, [Cocktail.hour_number] | nil} | {:error, term}
  defp parse_hours(%{"hours" => []}), do: {:ok, nil}
  defp parse_hours(%{"hours" => hours}) when is_list(hours), do: do_parse_hours(hours, [])
  defp parse_hours(%{"hours" => nil}), do: {:ok, nil}
  defp parse_hours(%{"hours" => _}), do: {:error, :invalid_hours}
  defp parse_hours(_), do: {:ok, nil}

  @spec do_parse_hours([integer], [Cocktail.hour_number]) :: {:ok, [Cocktail.hour_number]} | {:error, :invalid_hour}
  defp do_parse_hours([], hours), do: {:ok, hours |> Enum.reverse}
  defp do_parse_hours([hour | rest], hours) do
    with {:ok, hour} <- parse_hour(hour), do: do_parse_hours(rest, [hour | hours])
  end

  @spec parse_hour(integer) :: {:ok, Cocktail.hour_number} | {:error, :invalid_hour}
  defp parse_hour(hour) when is_integer(hour) and hour >= 0 and hour < 24, do: {:ok, hour}
  defp parse_hour(_), do: {:error, :invalid_hour}
end
