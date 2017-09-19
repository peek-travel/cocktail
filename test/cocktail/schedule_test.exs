defmodule Cocktail.ScheduleTest do
  use ExUnit.Case

  alias Cocktail.{Schedule, Rule}

  doctest Cocktail.Schedule, import: true

  test "ending all recurrence rules of a schedule" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new
      |> Schedule.add_recurrence_rule(:daily, interval: 2)
      |> Schedule.add_recurrence_rule(:daily, interval: 3)
      |> Schedule.add_recurrence_rule(:daily, interval: 5)
      |> Schedule.end_all_recurrence_rules(~N[2017-10-09 09:00:00])

    assert %Schedule{recurrence_rules: rules} = schedule

    Enum.each(rules, fn(%Rule{until: until}) ->
      assert until == ~N[2017-10-09 09:00:00]
    end)

    times =
      schedule
      |> Schedule.occurrences
      |> Enum.to_list

    assert length(times) == 23
  end
end
