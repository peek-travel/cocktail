defmodule Cocktail.TimeOfDayTest do
  use ExUnit.Case

  alias Cocktail.{Schedule}

  import Cocktail.TestSupport.DateTimeSigil

  test "a daily schedule with a time of day option" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Schedule.new
      |> Schedule.add_recurrence_rule(:daily, times: [~T[10:00:00], ~T[12:30:00], ~T[17:45:00]])

    times = schedule |> Schedule.occurrences |> Enum.take(6)

    assert times == [
      ~N[2017-09-09 10:00:00], ~N[2017-09-09 12:30:00], ~N[2017-09-09 17:45:00],
      ~N[2017-09-10 10:00:00], ~N[2017-09-10 12:30:00], ~N[2017-09-10 17:45:00]
    ]
  end

  test "a daily schedule with a zoned datetime and a time of day option" do
    schedule =
      ~N[2017-09-09 09:00:00]
      |> Timex.to_datetime("America/Chicago")
      |> Schedule.new
      |> Schedule.add_recurrence_rule(:daily, times: [~T[10:00:00], ~T[12:30:00], ~T[17:45:00]])

    times = schedule |> Schedule.occurrences |> Enum.take(6)

    assert times == [
      ~Y[2017-09-09 10:00:00 America/Chicago],
      ~Y[2017-09-09 12:30:00 America/Chicago],
      ~Y[2017-09-09 17:45:00 America/Chicago],
      ~Y[2017-09-10 10:00:00 America/Chicago],
      ~Y[2017-09-10 12:30:00 America/Chicago],
      ~Y[2017-09-10 17:45:00 America/Chicago]
    ]
  end
end
