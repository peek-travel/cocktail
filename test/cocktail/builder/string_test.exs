defmodule Cocktail.Builder.StringTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  doctest Cocktail.Builder.String, import: true

  test "build a schedule with a BYDAY option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday, :wednesday, :friday])

    string = Schedule.to_string(schedule)

    assert string == "Weekly on Mondays, Wednesdays and Fridays"
  end

  test "build a schedule with a BYHOUR option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, hours: [10, 12, 14])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 10th, 12th and 14th hours of the day"
  end

  test "build a schedule with a BYMINUTE option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, minutes: [0, 15, 30, 45])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 0th, 15th, 30th and 45th minutes of the hour"
  end

  test "build a schedule with a BYSECOND option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, seconds: [0, 30])

    string = Schedule.to_string(schedule)

    assert string == "Daily on the 0th and 30th seconds of the minute"
  end
end
