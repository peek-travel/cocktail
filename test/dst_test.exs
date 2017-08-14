defmodule DSTTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  test "test daily rule across DST boundary when time is 10am" do
    start_time = Timex.to_datetime({{2017, 3, 11}, {10, 0, 0}}, "America/Los_Angeles")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.to_datetime({{2017, 3, 11}, {10, 0, 0}}, "America/Los_Angeles"),
      Timex.to_datetime({{2017, 3, 12}, {10, 0, 0}}, "America/Los_Angeles"),
      Timex.to_datetime({{2017, 3, 13}, {10, 0, 0}}, "America/Los_Angeles")
    ]
  end

  @tag :pending
  test "test daily rule across DST boundary when time is 2:30am" do
    start_time = Timex.to_datetime({{2017, 3, 11}, {2, 30, 0}}, "America/Los_Angeles")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.to_datetime({{2017, 3, 11}, {2, 30, 0}}, "America/Los_Angeles"),
      Timex.to_datetime({{2017, 3, 12}, {3, 30, 0}}, "America/Los_Angeles"),
      Timex.to_datetime({{2017, 3, 13}, {2, 30, 0}}, "America/Los_Angeles")
    ]
  end
end
