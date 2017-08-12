defmodule CocktailTest do
  use ExUnit.Case
  doctest Cocktail

  alias Cocktail.Schedule

  test "create a schedule with a daily recurrence rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily)

    assert schedule == %Cocktail.Schedule{start_time: start_time, recurrence_rules: [%Cocktail.Rules.Daily{ interval: 1 }]}
  end

  test "evaluates daily recurrence rule with interval 1" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-12T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-13T16:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates daily recurrence rule with interval 2" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, interval: 2)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-13T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-15T16:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates a schedule with both a daily(2) and a daily(3) rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, interval: 2)
      |> Schedule.add_recurrence_rule(:daily, interval: 3)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(7)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-13T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-14T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-15T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-17T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-19T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-20T16:00:00-07:00", "{ISO:Extended}")
    ]
  end
end
