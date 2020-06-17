defmodule Cocktail.Builder.StringTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  doctest Cocktail.Builder.String, import: true

  test "build a schedule with a BYDAY option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday, :wednesday, :friday])

    string = Schedule.to_string(schedule)

    assert string == "Weekly on Mondays, Wednesdays and Fridays"
  end

  test "build a schedule with a BYDAY option, with only a single day" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday])

    string = Schedule.to_string(schedule)

    assert string == "Weekly on Mondays"
  end

  test "build a schedule with a BYHOUR option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, hours: [10, 12, 14])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 10th, 12th and 14th hours of the day"
  end

  test "build a schedule with a BYMINUTE option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, minutes: [0, 15, 30, 45])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 0th, 15th, 30th and 45th minutes of the hour"
  end

  test "build a schedule with a BYSECOND option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, seconds: [0, 30])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 0th and 30th seconds of the minute"
  end

  test "every second" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly)

    string = Schedule.to_string(schedule)

    assert string == "Secondly"
  end

  test "every 2 seconds" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly, interval: 2)

    string = Schedule.to_string(schedule)

    assert string == "Every 2 seconds"
  end

  test "every minute" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:minutely)

    string = Schedule.to_string(schedule)

    assert string == "Minutely"
  end

  test "every 2 minutes" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:minutely, interval: 2)

    string = Schedule.to_string(schedule)

    assert string == "Every 2 minutes"
  end

  test "every hour" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly)

    string = Schedule.to_string(schedule)

    assert string == "Hourly"
  end

  test "every 2 hours" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly, interval: 2)

    string = Schedule.to_string(schedule)

    assert string == "Every 2 hours"
  end

  test "on the 1st hour of the day" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, hours: [1])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 1st hour of the day"
  end

  test "on the 2nd minute of the hour" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, minutes: [2])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 2nd minute of the hour"
  end

  test "on the 3rd second of the minute" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, seconds: [3])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 3rd second of the minute"
  end

  test "every month" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)

    string = Schedule.to_string(schedule)

    assert string == "Monthly"
  end

  test "every 2 month" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 2)

    string = Schedule.to_string(schedule)

    assert string == "Every 2 months"
  end
end
