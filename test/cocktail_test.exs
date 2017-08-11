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
end
