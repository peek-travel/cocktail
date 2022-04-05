defmodule Cocktail.DailyTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  import Cocktail.TestSupport.DateTimeSigil

  test "Daily" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-01-01 06:00:00 America/Los_Angeles],
             ~Y[2017-01-02 06:00:00 America/Los_Angeles],
             ~Y[2017-01-03 06:00:00 America/Los_Angeles]
           ]
  end

  test "Every 2 days" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, interval: 2)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-01-01 06:00:00 America/Los_Angeles],
             ~Y[2017-01-03 06:00:00 America/Los_Angeles],
             ~Y[2017-01-05 06:00:00 America/Los_Angeles]
           ]
  end

  test "Every 2 days / Every 3 days" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, interval: 2)
      |> Schedule.add_recurrence_rule(:daily, interval: 3)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(7)

    assert times == [
             ~Y[2017-01-01 06:00:00 America/Los_Angeles],
             ~Y[2017-01-03 06:00:00 America/Los_Angeles],
             ~Y[2017-01-04 06:00:00 America/Los_Angeles],
             ~Y[2017-01-05 06:00:00 America/Los_Angeles],
             ~Y[2017-01-07 06:00:00 America/Los_Angeles],
             ~Y[2017-01-09 06:00:00 America/Los_Angeles],
             ~Y[2017-01-10 06:00:00 America/Los_Angeles]
           ]
  end

  test "Daily; overridden start time" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily)
      |> Cocktail.Schedule.occurrences(~Y[2017-08-01 12:00:00 America/Los_Angeles])
      |> Enum.take(3)

    assert times == [
             ~Y[2017-08-02 06:00:00 America/Los_Angeles],
             ~Y[2017-08-03 06:00:00 America/Los_Angeles],
             ~Y[2017-08-04 06:00:00 America/Los_Angeles]
           ]
  end

  test "Daily on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, hours: [10, 14])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(5)

    assert times == [
             ~Y[2017-01-01 10:00:00 America/Los_Angeles],
             ~Y[2017-01-01 14:00:00 America/Los_Angeles],
             ~Y[2017-01-02 10:00:00 America/Los_Angeles],
             ~Y[2017-01-02 14:00:00 America/Los_Angeles],
             ~Y[2017-01-03 10:00:00 America/Los_Angeles]
           ]
  end

  test "Every 6 days on Mondays and Fridays" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, interval: 6, days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(8)

    assert times == [
             ~Y[2017-01-13 06:00:00 America/Los_Angeles],
             ~Y[2017-02-06 06:00:00 America/Los_Angeles],
             ~Y[2017-02-24 06:00:00 America/Los_Angeles],
             ~Y[2017-03-20 06:00:00 America/Los_Angeles],
             ~Y[2017-04-07 06:00:00 America/Los_Angeles],
             ~Y[2017-05-01 06:00:00 America/Los_Angeles],
             ~Y[2017-05-19 06:00:00 America/Los_Angeles],
             ~Y[2017-06-12 06:00:00 America/Los_Angeles]
           ]
  end

  test "Daily on Mondays and Fridays on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, days: [:monday, :friday], hours: [10, 14])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(5)

    assert times == [
             ~Y[2017-01-02 10:00:00 America/Los_Angeles],
             ~Y[2017-01-02 14:00:00 America/Los_Angeles],
             ~Y[2017-01-06 10:00:00 America/Los_Angeles],
             ~Y[2017-01-06 14:00:00 America/Los_Angeles],
             ~Y[2017-01-09 10:00:00 America/Los_Angeles]
           ]
  end

  test "Daily on Mondays and Fridays on the 10th and 14th hours of the day on the 15th and 45th minutes of the hour on the 0th and 30th seconds of the minute" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(
        :daily,
        days: [:monday, :friday],
        hours: [10, 14],
        minutes: [15, 45],
        seconds: [0, 30]
      )
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(9)

    assert times == [
             ~Y[2017-01-02 10:15:00 America/Los_Angeles],
             ~Y[2017-01-02 10:15:30 America/Los_Angeles],
             ~Y[2017-01-02 10:45:00 America/Los_Angeles],
             ~Y[2017-01-02 10:45:30 America/Los_Angeles],
             ~Y[2017-01-02 14:15:00 America/Los_Angeles],
             ~Y[2017-01-02 14:15:30 America/Los_Angeles],
             ~Y[2017-01-02 14:45:00 America/Los_Angeles],
             ~Y[2017-01-02 14:45:30 America/Los_Angeles],
             ~Y[2017-01-06 10:15:00 America/Los_Angeles]
           ]
  end

  test "generating occurrences when when add_recurrence_time is used" do
    assert Cocktail.Schedule.new(~N[2015-01-08 18:30:00])
           |> Cocktail.Schedule.add_recurrence_rule(
             :daily,
             days: [:thursday, :friday, :wednesday],
             until: ~N[2015-01-14 18:30:00]
           )
           |> Cocktail.Schedule.add_recurrence_time(~N[2015-01-23 18:30:00])
           |> Cocktail.Schedule.add_recurrence_time(~N[2015-01-24 18:30:00])
           |> Cocktail.Schedule.occurrences(~N[2015-01-24 18:30:00])
           |> Enum.take(100) == [~N[2015-01-24 18:30:00]]
  end

  test "generating occurrences with spring forward transition" do
    schedule =
      ~Y[2022-03-12 18:00:00 America/Los_Angeles]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(:daily)

    times = schedule |> Schedule.occurrences() |> Enum.take(3)

    assert times == [
             ~Y[2022-03-12 18:00:00 America/Los_Angeles],
             ~Y[2022-03-13 18:00:00 America/Los_Angeles],
             ~Y[2022-03-14 18:00:00 America/Los_Angeles]
           ]
  end

  test "generating occurrences with fall back transition" do
    schedule =
      ~Y[2022-11-05 18:00:00 America/Los_Angeles]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(:daily)

    times = schedule |> Schedule.occurrences() |> Enum.take(3)

    assert times == [
             ~Y[2022-11-05 18:00:00 America/Los_Angeles],
             ~Y[2022-11-06 18:00:00 America/Los_Angeles],
             ~Y[2022-11-07 18:00:00 America/Los_Angeles]
           ]
  end
end
