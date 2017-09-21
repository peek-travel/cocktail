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

  test "an empty schedule produces a single occurrence at its start time" do
    schedule = ~N[2017-09-09 09:00:00] |> Schedule.new
    times = schedule |> Schedule.occurrences |> Enum.to_list

    assert times == [~N[2017-09-09 09:00:00]]
  end

  test "recurrence times" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new
      |> Schedule.add_recurrence_time(~N[2017-09-09 09:00:00])
      |> Schedule.add_recurrence_time(~N[2017-09-10 09:00:00])

    times = schedule |> Schedule.occurrences |> Enum.to_list

    assert times == [~N[2017-09-09 09:00:00], ~N[2017-09-10 09:00:00]]
  end

  test "exception times" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new
      |> Schedule.add_recurrence_rule(:daily)
      |> Schedule.add_exception_time(~N[2017-09-10 09:00:00])

    times = schedule |> Schedule.occurrences |> Enum.take(2)

    assert times == [~N[2017-09-09 09:00:00], ~N[2017-09-11 09:00:00]]
  end

  test "add recurrence rule with bad options" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new
      |> Schedule.add_recurrence_rule(:daily, ignore: :me)

    times = schedule |> Schedule.occurrences |> Enum.take(2)

    assert times == [~N[2017-09-09 09:00:00], ~N[2017-09-10 09:00:00]]
  end

  test "add day of week recurrence rule with day numbers instead of atoms" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new
      |> Schedule.add_recurrence_rule(:weekly, days: [1, 3, 5])

    times = schedule |> Schedule.occurrences |> Enum.take(3)

    assert times == [~N[2017-09-11 09:00:00], ~N[2017-09-13 09:00:00], ~N[2017-09-15 09:00:00]]
  end

  test "a schedule with a recurrence rule and a recurrence time" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new
      |> Schedule.add_recurrence_rule(:daily, interval: 2)
      |> Schedule.add_recurrence_time(~N[2017-09-12 09:00:00])

    times = schedule |> Schedule.occurrences |> Enum.take(3)

    assert times == [~N[2017-09-09 09:00:00], ~N[2017-09-11 09:00:00], ~N[2017-09-12 09:00:00]]
  end
end
