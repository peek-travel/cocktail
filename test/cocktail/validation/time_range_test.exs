defmodule Cocktail.TimeRangeTest do
  use ExUnit.Case

  alias Cocktail.{Schedule}

  import Cocktail.TestSupport.DateTimeSigil

  test "a daily schedule with a time range option" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(
        :daily,
        time_range: %{start_time: ~T[09:00:00], end_time: ~T[11:00:00], interval_seconds: 1_800}
      )

    times = schedule |> Schedule.occurrences() |> Enum.take(6)

    assert times == [
             ~N[2017-09-09 09:00:00],
             ~N[2017-09-09 09:30:00],
             ~N[2017-09-09 10:00:00],
             ~N[2017-09-09 10:30:00],
             ~N[2017-09-09 11:00:00],
             ~N[2017-09-10 09:00:00]
           ]
  end

  test "a daily schedule with a zoned datetime and a time range option" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Timex.to_datetime("America/Chicago")
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(
        :daily,
        time_range: %{start_time: ~T[09:00:00], end_time: ~T[11:00:00], interval_seconds: 1_800}
      )

    times = schedule |> Schedule.occurrences() |> Enum.take(6)

    assert times == [
             ~Y[2017-09-09 09:00:00 America/Chicago],
             ~Y[2017-09-09 09:30:00 America/Chicago],
             ~Y[2017-09-09 10:00:00 America/Chicago],
             ~Y[2017-09-09 10:30:00 America/Chicago],
             ~Y[2017-09-09 11:00:00 America/Chicago],
             ~Y[2017-09-10 09:00:00 America/Chicago]
           ]
  end
end
