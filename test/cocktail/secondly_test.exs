defmodule Cocktail.SecondlyTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  import Cocktail.TestSupport.DateTimeSigil

  test "Secondly" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-01-01 06:00:00 America/Los_Angeles],
             ~Y[2017-01-01 06:00:01 America/Los_Angeles],
             ~Y[2017-01-01 06:00:02 America/Los_Angeles]
           ]
  end

  test "Every 2 seconds" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly, interval: 2)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-01-01 06:00:00 America/Los_Angeles],
             ~Y[2017-01-01 06:00:02 America/Los_Angeles],
             ~Y[2017-01-01 06:00:04 America/Los_Angeles]
           ]
  end

  test "Every 2 seconds / Every 3 seconds" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly, interval: 2)
      |> Schedule.add_recurrence_rule(:secondly, interval: 3)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(7)

    assert times == [
             ~Y[2017-01-01 06:00:00 America/Los_Angeles],
             ~Y[2017-01-01 06:00:02 America/Los_Angeles],
             ~Y[2017-01-01 06:00:03 America/Los_Angeles],
             ~Y[2017-01-01 06:00:04 America/Los_Angeles],
             ~Y[2017-01-01 06:00:06 America/Los_Angeles],
             ~Y[2017-01-01 06:00:08 America/Los_Angeles],
             ~Y[2017-01-01 06:00:09 America/Los_Angeles]
           ]
  end

  test "Secondly; overridden start time" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly)
      |> Cocktail.Schedule.occurrences(~Y[2017-08-01 12:00:00 America/Los_Angeles])
      |> Enum.take(3)

    assert times == [
             ~Y[2017-08-01 12:00:00 America/Los_Angeles],
             ~Y[2017-08-01 12:00:01 America/Los_Angeles],
             ~Y[2017-08-01 12:00:02 America/Los_Angeles]
           ]
  end

  test "Every 900 seconds on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly, interval: 900, hours: [10, 14])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(9)

    assert times == [
             ~Y[2017-01-01 10:00:00 America/Los_Angeles],
             ~Y[2017-01-01 10:15:00 America/Los_Angeles],
             ~Y[2017-01-01 10:30:00 America/Los_Angeles],
             ~Y[2017-01-01 10:45:00 America/Los_Angeles],
             ~Y[2017-01-01 14:00:00 America/Los_Angeles],
             ~Y[2017-01-01 14:15:00 America/Los_Angeles],
             ~Y[2017-01-01 14:30:00 America/Los_Angeles],
             ~Y[2017-01-01 14:45:00 America/Los_Angeles],
             ~Y[2017-01-02 10:00:00 America/Los_Angeles]
           ]
  end

  test "Every 21,600 seconds on Mondays and Fridays" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly, interval: 21_600, days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(9)

    assert times == [
             ~Y[2017-01-02 00:00:00 America/Los_Angeles],
             ~Y[2017-01-02 06:00:00 America/Los_Angeles],
             ~Y[2017-01-02 12:00:00 America/Los_Angeles],
             ~Y[2017-01-02 18:00:00 America/Los_Angeles],
             ~Y[2017-01-06 00:00:00 America/Los_Angeles],
             ~Y[2017-01-06 06:00:00 America/Los_Angeles],
             ~Y[2017-01-06 12:00:00 America/Los_Angeles],
             ~Y[2017-01-06 18:00:00 America/Los_Angeles],
             ~Y[2017-01-09 00:00:00 America/Los_Angeles]
           ]
  end

  test "Every 1,800 seconds on Mondays and Fridays on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 America/Los_Angeles]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:secondly, interval: 1_800, hours: [10, 14], days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(9)

    assert times == [
             ~Y[2017-01-02 10:00:00 America/Los_Angeles],
             ~Y[2017-01-02 10:30:00 America/Los_Angeles],
             ~Y[2017-01-02 14:00:00 America/Los_Angeles],
             ~Y[2017-01-02 14:30:00 America/Los_Angeles],
             ~Y[2017-01-06 10:00:00 America/Los_Angeles],
             ~Y[2017-01-06 10:30:00 America/Los_Angeles],
             ~Y[2017-01-06 14:00:00 America/Los_Angeles],
             ~Y[2017-01-06 14:30:00 America/Los_Angeles],
             ~Y[2017-01-09 10:00:00 America/Los_Angeles]
           ]
  end
end
