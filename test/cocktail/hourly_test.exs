defmodule Cocktail.HourlyTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  import Cocktail.TestSupport.DateTimeSigil

  test "Hourly" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-01-01 06:00:00 PST],
             ~Y[2017-01-01 07:00:00 PST],
             ~Y[2017-01-01 08:00:00 PST]
           ]
  end

  test "Every 2 hours" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly, interval: 2)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-01-01 06:00:00 PST],
             ~Y[2017-01-01 08:00:00 PST],
             ~Y[2017-01-01 10:00:00 PST]
           ]
  end

  test "Every 2 hours / Every 3 hours" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly, interval: 2)
      |> Schedule.add_recurrence_rule(:hourly, interval: 3)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(7)

    assert times == [
             ~Y[2017-01-01 06:00:00 PST],
             ~Y[2017-01-01 08:00:00 PST],
             ~Y[2017-01-01 09:00:00 PST],
             ~Y[2017-01-01 10:00:00 PST],
             ~Y[2017-01-01 12:00:00 PST],
             ~Y[2017-01-01 14:00:00 PST],
             ~Y[2017-01-01 15:00:00 PST]
           ]
  end

  test "Hourly; overridden start time" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly)
      |> Cocktail.Schedule.occurrences(~Y[2017-08-01 12:00:00 PDT])
      |> Enum.take(3)

    assert times == [
             ~Y[2017-08-01 12:00:00 PDT],
             ~Y[2017-08-01 13:00:00 PDT],
             ~Y[2017-08-01 14:00:00 PDT]
           ]
  end

  test "Hourly on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly, hours: [10, 14])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(5)

    assert times == [
             ~Y[2017-01-01 10:00:00 PST],
             ~Y[2017-01-01 14:00:00 PST],
             ~Y[2017-01-02 10:00:00 PST],
             ~Y[2017-01-02 14:00:00 PST],
             ~Y[2017-01-03 10:00:00 PST]
           ]
  end

  test "Every 6 hours on Mondays and Fridays" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly, interval: 6, days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences()
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

  test "Hourly on Mondays and Fridays on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 PST]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:hourly, hours: [10, 14], days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(5)

    assert times == [
             ~Y[2017-01-02 10:00:00 PST],
             ~Y[2017-01-02 14:00:00 PST],
             ~Y[2017-01-06 10:00:00 PST],
             ~Y[2017-01-06 14:00:00 PST],
             ~Y[2017-01-09 10:00:00 PST]
           ]
  end
end
