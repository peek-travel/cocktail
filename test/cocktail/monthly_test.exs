defmodule Cocktail.MonthlyTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  import Cocktail.TestSupport.DateTimeSigil

  test "Monthly" do
    times =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-01-01 06:00:00 UTC],
             ~Y[2017-02-01 06:00:00 UTC],
             ~Y[2017-03-01 06:00:00 UTC]
           ]
  end

  test "Monthly starting on 31th March 2017" do
    times =
      ~Y[2017-03-31 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-03-31 06:00:00 UTC],
             ~Y[2017-04-30 06:00:00 UTC],
             ~Y[2017-05-31 06:00:00 UTC]
           ]
  end

  test "Monthly starting on 28th Feb 2017" do
    times =
      ~Y[2017-02-28 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-02-28 06:00:00 UTC],
             ~Y[2017-03-28 06:00:00 UTC],
             ~Y[2017-04-28 06:00:00 UTC]
           ]
  end

  test "every 12 month starting on 29th Feb 2020" do
    times =
      ~Y[2020-02-29 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 12)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2020-02-29 06:00:00 UTC],
             ~Y[2021-02-28 06:00:00 UTC],
             ~Y[2022-02-28 06:00:00 UTC]
           ]
  end

  test "Monthly: starting on 7th Nov 2019 and should return 7 th Nov 2039 after 20 years " do
    times =
      ~Y[2019-11-07 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)
      |> Cocktail.Schedule.occurrences()
      |> Enum.at(20 * 12)

    assert times == ~Y[2039-11-07 06:00:00 UTC]
  end

  test "Every 2 months" do
    times =
      ~Y[2017-02-28 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 2)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(3)

    assert times == [
             ~Y[2017-02-28 06:00:00 UTC],
             ~Y[2017-04-28 06:00:00 UTC],
             ~Y[2017-06-28 06:00:00 UTC]
           ]
  end

  test "Every 2 / 3 months" do
    times =
      ~Y[2017-01-02 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 2)
      |> Schedule.add_recurrence_rule(:monthly, interval: 3)
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(7)

    assert times == [
             ~Y[2017-01-02 06:00:00 UTC],
             ~Y[2017-03-02 06:00:00 UTC],
             ~Y[2017-04-02 06:00:00 UTC],
             ~Y[2017-05-02 06:00:00 UTC],
             ~Y[2017-07-02 06:00:00 UTC],
             ~Y[2017-09-02 06:00:00 UTC],
             ~Y[2017-10-02 06:00:00 UTC]
           ]
  end

  test "Monthly; overridden start month" do
    times =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)
      |> Cocktail.Schedule.occurrences(~Y[2017-05-01 06:00:00 UTC])
      |> Enum.take(3)

    assert times == [
             ~Y[2017-05-01 06:00:00 UTC],
             ~Y[2017-06-01 06:00:00 UTC],
             ~Y[2017-07-01 06:00:00 UTC]
           ]
  end

  test "Monthly on Mondays and Fridays" do
    times =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days: [:monday, :friday])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(8)

    assert times == [
             ~Y[2017-05-01 06:00:00 UTC],
             ~Y[2017-09-01 06:00:00 UTC],
             ~Y[2017-12-01 06:00:00 UTC],
             ~Y[2018-01-01 06:00:00 UTC],
             ~Y[2018-06-01 06:00:00 UTC],
             ~Y[2018-10-01 06:00:00 UTC],
             ~Y[2019-02-01 06:00:00 UTC],
             ~Y[2019-03-01 06:00:00 UTC]
           ]
  end

  test "Monthly on the 10th and 14th hours of the day" do
    times =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, hours: [10, 14])
      |> Cocktail.Schedule.occurrences()
      |> Enum.take(5)

    assert times == [
             ~Y[2017-01-01 10:00:00 UTC],
             ~Y[2017-01-01 14:00:00 UTC],
             ~Y[2017-02-01 10:00:00 UTC],
             ~Y[2017-02-01 14:00:00 UTC],
             ~Y[2017-03-01 10:00:00 UTC]
           ]
  end
end
