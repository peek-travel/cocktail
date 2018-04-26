defmodule Cocktail.ReversibilityTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  defp assert_reversible(schedule) do
    i_calendar_string = Schedule.to_i_calendar(schedule)
    {:ok, parsed_schedule} = Schedule.from_i_calendar(i_calendar_string)

    assert parsed_schedule == schedule
  end

  for frequency <- [:secondly, :minutely, :hourly, :daily, :weekly] do
    test "#{frequency}" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency))
      |> assert_reversible()
    end

    test "#{frequency} interval 2" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency), interval: 2)
      |> assert_reversible()
    end

    test "#{frequency} on Mondays, Wednesdays and Fridays" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency), days: [:monday, :wednesday, :friday])
      |> assert_reversible()
    end

    test "#{frequency} on the 10th, 12th and 14th hours of the day" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency), hours: [10, 12, 14])
      |> assert_reversible()
    end

    test "#{frequency} on the 0th and 30th minutes of the hour" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency), minutes: [0, 30])
      |> assert_reversible()
    end

    test "#{frequency} on the 0th and 30th seconds of the minute" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency), seconds: [0, 30])
      |> assert_reversible()
    end

    test "#{frequency} until someday" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency), until: ~N[2017-10-09 09:00:00])
      |> assert_reversible()
    end

    test "#{frequency} 10 times" do
      ~N[2017-09-09 09:00:00]
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(unquote(frequency), count: 10)
      |> assert_reversible()
    end
  end

  test "recurrence times" do
    ~N[2017-09-09 09:00:00]
    |> Schedule.new()
    |> Schedule.add_recurrence_time(~N[2017-10-09 09:00:00])
    |> assert_reversible()
  end

  test "exception times" do
    ~N[2017-09-09 09:00:00]
    |> Schedule.new()
    |> Schedule.add_recurrence_rule(:daily)
    |> Schedule.add_exception_time(~N[2017-09-10 09:00:00])
    |> assert_reversible()
  end

  test "time of day option" do
    ~N[2017-09-09 09:00:00]
    |> Schedule.new()
    |> Schedule.add_recurrence_rule(:daily, times: [~T[09:00:00], ~T[11:30:00]])
    |> assert_reversible()
  end

  test "time range option" do
    ~N[2017-09-09 09:00:00]
    |> Schedule.new()
    |> Schedule.add_recurrence_rule(
      :daily,
      time_range: %{start_time: ~T[09:00:00], end_time: ~T[11:00:00], interval_seconds: 1_800}
    )
    |> assert_reversible()
  end

  test "empty days" do
    ~N[2017-09-09 09:00:00] |> Schedule.new() |> Schedule.add_recurrence_rule(:daily, days: []) |> assert_reversible()
  end

  test "empty hours" do
    ~N[2017-09-09 09:00:00] |> Schedule.new() |> Schedule.add_recurrence_rule(:daily, hours: []) |> assert_reversible()
  end

  test "empty minutes" do
    ~N[2017-09-09 09:00:00]
    |> Schedule.new()
    |> Schedule.add_recurrence_rule(:daily, minutes: [])
    |> assert_reversible()
  end

  test "empty seconds" do
    ~N[2017-09-09 09:00:00]
    |> Schedule.new()
    |> Schedule.add_recurrence_rule(:daily, seconds: [])
    |> assert_reversible()
  end

  test "empty times" do
    ~N[2017-09-09 09:00:00] |> Schedule.new() |> Schedule.add_recurrence_rule(:daily, times: []) |> assert_reversible()
  end
end
