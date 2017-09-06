defmodule Cocktail.Builder.String do
  @moduledoc """
  Build human readable strings from schedules.
  """

  alias Cocktail.{Rule, Schedule}
  alias Cocktail.Validation.{Interval, Day, HourOfDay}

  @doc """
  Builds a human readable string represenation of a `t:Cocktail.Schedule.t/0`.

  ## Examples

      iex> alias Cocktail.Schedule
      ...> start_time = Timex.to_datetime(~N[2017-01-01 06:00:00], "America/Los_Angeles")
      ...> schedule = Schedule.new(start_time)
      ...> schedule = Schedule.add_recurrence_rule(schedule, :daily, interval: 2, hours: [10, 12])
      ...> build(schedule)
      "Every 2 days on the 10th and 12th hours of the day"
  """
  # @spec build(Schedule.t) :: String.t # FIXME: for some reason this spec doesn't work
  def build(%Schedule{recurrence_rules: recurrence_rules}) do
    recurrence_rules
    |> Enum.map(&build_rule/1)
    |> Enum.join(" / ")
  end

  @doc false
  @spec build_rule(Rule.t) :: String.t
  def build_rule(%Rule{validations: validations_map}) do
    for key <- [:interval, :day, :hour_of_day],
        validations = validations_map[key],
        is_list(validations)
    do
      build_validation_part(key, validations)
    end
    |> Enum.join(" ")
  end

  @spec build_validation_part(:interval | :day | :hour_of_day, [Cocktail.Validation.t]) :: String.t
  defp build_validation_part(:interval, [%Interval{interval: interval, type: type}]), do: build_interval(type, interval)
  defp build_validation_part(:day, days), do: days |> Enum.map(fn(%Day{day: day}) -> day end) |> build_days()
  defp build_validation_part(:hour_of_day, hours), do: hours |> Enum.map(fn(%HourOfDay{hour: hour}) -> hour end) |> build_hours()

  # intervals

  @spec build_interval(Cocktail.frequency, pos_integer) :: String.t
  defp build_interval(:secondly, 1), do: "Secondly"
  defp build_interval(:secondly, n), do: "Every #{n} seconds"
  defp build_interval(:minutely, 1), do: "Minutely"
  defp build_interval(:minutely, n), do: "Every #{n} minutes"
  defp build_interval(:hourly, 1), do: "Hourly"
  defp build_interval(:hourly, n), do: "Every #{n} hours"
  defp build_interval(:daily, 1), do: "Daily"
  defp build_interval(:daily, n), do: "Every #{n} days"
  defp build_interval(:weekly, 1), do: "Weekly"
  defp build_interval(:weekly, n), do: "Every #{n} weeks"
  defp build_interval(:monthly, 1), do: "Monthly"
  defp build_interval(:monthly, n), do: "Every #{n} months"
  defp build_interval(:yearly, 1), do: "Yearly"
  defp build_interval(:yearly, n), do: "Every #{n} years"

  # "day" validation

  @spec build_days([Cocktail.day_number]) :: String.t
  defp build_days(days) do
    days
    |> Enum.sort
    |> build_days_sentence()
  end

  @spec build_days_sentence([Cocktail.day_number]) :: String.t
  defp build_days_sentence([0, 6]), do: "on Weekends"
  defp build_days_sentence([1, 2, 3, 4, 5]), do: "on Weekdays"
  defp build_days_sentence(days), do: "on " <> (days |> Enum.map(&on_days/1) |> sentence)

  @spec on_days(Cocktail.day_number) :: String.t
  defp on_days(0), do: "Sundays"
  defp on_days(1), do: "Mondays"
  defp on_days(2), do: "Tuesdays"
  defp on_days(3), do: "Wednesdays"
  defp on_days(4), do: "Thursdays"
  defp on_days(5), do: "Fridays"
  defp on_days(6), do: "Saturdays"

  # "hour of day" validation

  @spec build_hours([Cocktail.hour_number]) :: String.t
  defp build_hours(hours) do
    hours
    |> Enum.sort
    |> build_hours_sentence()
  end

  @spec build_hours_sentence([Cocktail.hour_number]) :: String.t
  defp build_hours_sentence([hour]), do: "on the #{ordinalize(hour)} hour of the day"
  defp build_hours_sentence(hours), do: "on the " <> (hours |> Enum.map(&ordinalize/1) |> sentence()) <> " hours of the day"

  # utils

  @spec sentence([String.t]) :: String.t
  defp sentence([]), do: ""
  defp sentence([word]), do: word
  defp sentence([first, second]), do: "#{first} and #{second}"
  defp sentence(words) do
    {words, [last]} = Enum.split(words, -1)
    first_half = words |> Enum.join(", ")
    "#{first_half} and #{last}"
  end

  @spec ordinalize(integer) :: String.t
  defp ordinalize(n) when n < 0, do: n |> abs() |> ordinalize()
  defp ordinalize(n) when rem(n, 100) in 4..20, do: "#{n}th"
  defp ordinalize(n) do
    case rem(n, 10) do
      1 -> "#{n}st"
      2 -> "#{n}nd"
      3 -> "#{n}rd"
      _ -> "#{n}th"
    end
  end
end
