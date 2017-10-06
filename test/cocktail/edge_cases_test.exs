defmodule Cocktail.EdgeCasesTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  test "override start time to before the schedule's start time" do
    schedule = Schedule.new(~N[2017-10-01 09:00:00]) |> Schedule.add_recurrence_rule(:daily)

    times = Schedule.occurrences(schedule, ~N[2017-09-01 00:00:00]) |> Enum.take(3)

    assert times == [
      ~N[2017-10-01 09:00:00],
      ~N[2017-10-02 09:00:00],
      ~N[2017-10-03 09:00:00]
    ]
  end
end
