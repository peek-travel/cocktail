defmodule Cocktail.MinutelyTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  import Cocktail.TestSupport.DateTimeSigil

  test "Minutely" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely)
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      ~Y[2017-01-01 06:00:00 PST],
      ~Y[2017-01-01 06:01:00 PST],
      ~Y[2017-01-01 06:02:00 PST]
    ]
  end

  test "Every 2 minutes" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely, interval: 2)
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      ~Y[2017-01-01 06:00:00 PST],
      ~Y[2017-01-01 06:02:00 PST],
      ~Y[2017-01-01 06:04:00 PST]
    ]
  end

  test "Every 2 minutes / Every 3 minutes" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely, interval: 2)
      |> Schedule.add_recurrence_rule(:minutely, interval: 3)
      |> Cocktail.Schedule.occurrences
      |> Enum.take(7)

    assert times == [
      ~Y[2017-01-01 06:00:00 PST],
      ~Y[2017-01-01 06:02:00 PST],
      ~Y[2017-01-01 06:03:00 PST],
      ~Y[2017-01-01 06:04:00 PST],
      ~Y[2017-01-01 06:06:00 PST],
      ~Y[2017-01-01 06:08:00 PST],
      ~Y[2017-01-01 06:09:00 PST]
    ]
  end

  test "Minutely; overridden start time" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely)
      |> Cocktail.Schedule.occurrences(~Y[2017-08-01 12:00:00 PDT])
      |> Enum.take(3)

    assert times == [
      ~Y[2017-08-01 12:00:00 PDT],
      ~Y[2017-08-01 12:01:00 PDT],
      ~Y[2017-08-01 12:02:00 PDT]
    ]
  end

  test "Every 15 minutes on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely, interval: 15, hours: [10, 14])
      |> Cocktail.Schedule.occurrences
      |> Enum.take(9)

    assert times == [
      ~Y[2017-01-01 10:00:00 PST],
      ~Y[2017-01-01 10:15:00 PST],
      ~Y[2017-01-01 10:30:00 PST],
      ~Y[2017-01-01 10:45:00 PST],
      ~Y[2017-01-01 14:00:00 PST],
      ~Y[2017-01-01 14:15:00 PST],
      ~Y[2017-01-01 14:30:00 PST],
      ~Y[2017-01-01 14:45:00 PST],
      ~Y[2017-01-02 10:00:00 PST]
    ]
  end

  test "Every 360 minutes on Mondays and Fridays" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely, interval: 360, days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences
      |> Enum.take(9)

    assert times == [
      ~Y[2017-01-02 00:00:00 PST],
      ~Y[2017-01-02 06:00:00 PST],
      ~Y[2017-01-02 12:00:00 PST],
      ~Y[2017-01-02 18:00:00 PST],
      ~Y[2017-01-06 00:00:00 PST],
      ~Y[2017-01-06 06:00:00 PST],
      ~Y[2017-01-06 12:00:00 PST],
      ~Y[2017-01-06 18:00:00 PST],
      ~Y[2017-01-09 00:00:00 PST]
    ]
  end

  test "Every 30 minutes on Mondays and Fridays on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely, interval: 30, hours: [10, 14],  days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences
      |> Enum.take(9)

    assert times == [
      ~Y[2017-01-02 10:00:00 PST],
      ~Y[2017-01-02 10:30:00 PST],
      ~Y[2017-01-02 14:00:00 PST],
      ~Y[2017-01-02 14:30:00 PST],
      ~Y[2017-01-06 10:00:00 PST],
      ~Y[2017-01-06 10:30:00 PST],
      ~Y[2017-01-06 14:00:00 PST],
      ~Y[2017-01-06 14:30:00 PST],
      ~Y[2017-01-09 10:00:00 PST]
    ]
  end
end
