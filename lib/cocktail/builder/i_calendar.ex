defmodule Cocktail.Builder.ICalendar do
  @moduledoc """
  Build iCalendar format strings from schedules.

  TODO: write long description
  """

  alias Cocktail.{Rule, Schedule, Validation}
  alias Cocktail.Validation.{Interval, Day, HourOfDay, MinuteOfHour, SecondOfMinute, TimeOfDay, TimeRange}

  @time_format_string "{YYYY}{0M}{0D}T{h24}{m}{s}"

  @doc ~S"""
  Builds an iCalendar format string represenation of a `t:Cocktail.Schedule.t/0`.

  ## Examples

      iex> alias Cocktail.Schedule
      ...> start_time = Timex.to_datetime(~N[2017-01-01 06:00:00], "America/Los_Angeles")
      ...> schedule = Schedule.new(start_time)
      ...> schedule = Schedule.add_recurrence_rule(schedule, :daily, interval: 2, hours: [10, 12])
      ...> build(schedule)
      "DTSTART;TZID=America/Los_Angeles:20170101T060000\nRRULE:FREQ=DAILY;INTERVAL=2;BYHOUR=10,12"

      iex> alias Cocktail.Schedule
      ...> schedule = Schedule.new(~N[2017-01-01 06:00:00])
      ...> schedule = Schedule.add_recurrence_rule(schedule, :daily, until: ~N[2017-01-31 11:59:59])
      ...> build(schedule)
      "DTSTART:20170101T060000\nRRULE:FREQ=DAILY;UNTIL=20170131T115959"

      iex> alias Cocktail.Schedule
      ...> schedule = Schedule.new(~N[2017-01-01 06:00:00])
      ...> schedule = Schedule.add_recurrence_rule(schedule, :daily, count: 3)
      ...> build(schedule)
      "DTSTART:20170101T060000\nRRULE:FREQ=DAILY;COUNT=3"
  """
  @spec build(Schedule.t()) :: String.t()
  def build(schedule) do
    rules =
      schedule.recurrence_rules
      |> Enum.map(&build_rule/1)

    times =
      schedule.recurrence_times
      |> Enum.map(&build_time(&1, "RDATE"))

    exceptions =
      schedule.exception_times
      |> Enum.map(&build_time(&1, "EXDATE"))

    start_time = build_start_time(schedule.start_time)
    end_time = build_end_time(schedule)

    ([start_time] ++ rules ++ times ++ exceptions ++ [end_time])
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  @spec build_time(Cocktail.time(), String.t()) :: String.t()
  defp build_time(%DateTime{} = time, prefix) do
    timezone = time.time_zone
    time_string = Timex.format!(time, @time_format_string)
    "#{prefix};TZID=#{timezone}:#{time_string}"
  end

  defp build_time(%NaiveDateTime{} = time, prefix) do
    time_string = Timex.format!(time, @time_format_string)
    "#{prefix}:#{time_string}"
  end

  @spec build_start_time(Cocktail.time()) :: String.t()
  defp build_start_time(time), do: build_time(time, "DTSTART")

  @spec build_end_time(Schedule.t()) :: String.t() | nil
  defp build_end_time(%Schedule{duration: nil}), do: nil

  defp build_end_time(%Schedule{start_time: start_time, duration: duration}) do
    start_time
    |> Timex.shift(seconds: duration)
    |> build_time("DTEND")
  end

  @spec build_utc_time(Cocktail.time()) :: String.t()
  defp build_utc_time(%NaiveDateTime{} = time), do: Timex.format!(time, @time_format_string)

  defp build_utc_time(%DateTime{} = time) do
    time
    |> Timex.to_datetime("UTC")
    |> Timex.format!(@time_format_string <> "Z")
  end

  @spec build_rule(Rule.t()) :: String.t()
  defp build_rule(%Rule{validations: validations_map, until: until, count: count}) do
    parts =
      for key <- [:interval, :day, :hour_of_day, :minute_of_hour, :second_of_minute, :time_of_day, :time_range],
          validation = validations_map[key],
          !is_nil(validation) do
        build_validation_part(key, validation)
      end

    parts = parts ++ build_until(until) ++ build_count(count)

    "RRULE:" <> (parts |> Enum.join(";"))
  end

  @spec build_validation_part(Validation.validation_key(), Validation.t()) :: String.t()
  defp build_validation_part(:interval, %Interval{interval: interval, type: type}), do: build_interval(type, interval)
  defp build_validation_part(:day, %Day{days: days}), do: days |> build_days()
  defp build_validation_part(:hour_of_day, %HourOfDay{hours: hours}), do: hours |> build_hours()
  defp build_validation_part(:minute_of_hour, %MinuteOfHour{minutes: minutes}), do: minutes |> build_minutes()
  defp build_validation_part(:second_of_minute, %SecondOfMinute{seconds: seconds}), do: seconds |> build_seconds()
  defp build_validation_part(:time_of_day, %TimeOfDay{times: times}), do: times |> build_times()
  defp build_validation_part(:time_range, %TimeRange{} = time_range), do: time_range |> build_time_range()

  @spec build_until(Cocktail.time() | nil) :: [String.t()]
  defp build_until(nil), do: []
  defp build_until(time), do: ["UNTIL=" <> build_utc_time(time)]

  @spec build_count(pos_integer | nil) :: [String.t()]
  defp build_count(nil), do: []
  defp build_count(count), do: ["COUNT=#{count}"]

  # intervals

  @spec build_interval(Cocktail.frequency(), pos_integer) :: String.t()
  defp build_interval(type, 1), do: "FREQ=" <> build_frequency(type)
  defp build_interval(type, n), do: "FREQ=" <> build_frequency(type) <> ";INTERVAL=#{n}"

  @spec build_frequency(Cocktail.frequency()) :: String.t()
  defp build_frequency(type), do: type |> Atom.to_string() |> String.upcase()

  # "day" validation

  @spec build_days([Cocktail.day_number()]) :: String.t()
  defp build_days(days) do
    days_list =
      days
      |> Enum.sort()
      |> Enum.map(&by_day/1)
      |> Enum.join(",")

    "BYDAY=#{days_list}"
  end

  @spec by_day(Cocktail.day_number()) :: String.t()
  defp by_day(0), do: "SU"
  defp by_day(1), do: "MO"
  defp by_day(2), do: "TU"
  defp by_day(3), do: "WE"
  defp by_day(4), do: "TH"
  defp by_day(5), do: "FR"
  defp by_day(6), do: "SA"

  # "hour of day" validation

  @spec build_hours([Cocktail.hour_number()]) :: String.t()
  defp build_hours(hours) do
    hours_list =
      hours
      |> Enum.sort()
      |> Enum.join(",")

    "BYHOUR=#{hours_list}"
  end

  # "minute of hour" validation

  @spec build_minutes([Cocktail.minute_number()]) :: String.t()
  defp build_minutes(minutes) do
    minutes_list =
      minutes
      |> Enum.sort()
      |> Enum.join(",")

    "BYMINUTE=#{minutes_list}"
  end

  # "second of minute" validation

  @spec build_seconds([Cocktail.second_number()]) :: String.t()
  defp build_seconds(seconds) do
    seconds_list =
      seconds
      |> Enum.sort()
      |> Enum.join(",")

    "BYSECOND=#{seconds_list}"
  end

  # "time of day" validation

  @spec build_times([TimeOfDay.time()]) :: String.t()
  defp build_times(times) do
    times_list =
      times
      |> Enum.sort()
      |> Enum.map(&format_erl_time/1)
      |> Enum.join(",")

    "X-BYTIME=#{times_list}"
  end

  defp format_erl_time({hour, min, sec}) do
    hours = String.pad_leading("#{hour}", 2, "0")
    mins = String.pad_leading("#{min}", 2, "0")
    secs = String.pad_leading("#{sec}", 2, "0")

    "#{hours}#{mins}#{secs}"
  end

  # "time range" validation

  @spec build_time_range(TimeRange.t()) :: String.t()
  defp build_time_range(%TimeRange{start_time: start_time, end_time: end_time, interval_seconds: interval}) do
    "X-BYRANGE=" <> ([format_time(start_time), format_time(end_time), interval] |> Enum.join(","))
  end

  defp format_time(time), do: time |> Time.to_erl() |> format_erl_time
end
