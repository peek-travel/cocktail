defmodule Cocktail.Builder.String do
  alias Cocktail.Rule
  alias Cocktail.Validation.{Interval, Day, HourOfDay}

  def build(schedule) do
    schedule.recurrence_rules
    |> Enum.map(&build_rule/1)
    |> Enum.join(" / ")
  end

  defp build_rule(%Rule{validations: validations}) do
    {parts, _} =
      [:interval, :day, :hour_of_day]
      |> Enum.reduce({[], validations}, &build_validation/2)
    parts |> Enum.reverse |> Enum.join(" ")
  end

  defp build_validation(key, {parts, validations_kwl}) do
    validations = Keyword.get(validations_kwl, key)
    if is_nil(validations) do
      {parts, validations_kwl}
    else
      part = build_validation_part(key, validations)
      {[part | parts], validations_kwl}
    end
  end

  defp build_validation_part(:interval, [%Interval{interval: interval, type: type}]), do: build_interval(type, interval)
  defp build_validation_part(:day, days), do: days |> Enum.map(fn(%Day{day: day}) -> day end) |> build_days()
  defp build_validation_part(:hour_of_day, hours), do: hours |> Enum.map(fn(%HourOfDay{hour: hour}) -> hour end) |> build_hours()

  # intervals

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

  defp build_days(days) do
    days
    |> Enum.sort
    |> build_days_sentence()
  end

  defp build_days_sentence([0, 6]), do: "on Weekends"
  defp build_days_sentence([1, 2, 3, 4, 5]), do: "on Weekdays"
  defp build_days_sentence(days), do: "on " <> (days |> Enum.map(&on_days/1) |> sentence)

  defp on_days(0), do: "Sundays"
  defp on_days(1), do: "Mondays"
  defp on_days(2), do: "Tuesdays"
  defp on_days(3), do: "Wednesdays"
  defp on_days(4), do: "Thursdays"
  defp on_days(5), do: "Fridays"
  defp on_days(6), do: "Saturdays"

  # "hour of day" validation

  defp build_hours(hours) do
    hours
    |> Enum.sort
    |> build_hours_sentence()
  end

  defp build_hours_sentence([hour]), do: "on the #{ordinalize(hour)} hour of the day"
  defp build_hours_sentence(hours), do: "on the " <> (hours |> Enum.map(&ordinalize/1) |> sentence()) <> " hours of the day"

  # utils

  defp sentence([]), do: ""
  defp sentence([word]), do: word
  defp sentence([first, second]), do: "#{first} and #{second}"
  defp sentence(words) do
    {words, [last]} = Enum.split(words, -1)
    first_half = words |> Enum.join(", ")
    "#{first_half} and #{last}"
  end

  defp ordinalize(n) do
    num = abs(n)
    ordinal = if rem(num, 100) in 4..20 do
                "th"
              else
                case rem(num, 10) do
                  1 -> "st"
                  2 -> "nd"
                  3 -> "rd"
                  _ -> "th"
                end
              end
    "#{n}#{ordinal}"
  end
end
