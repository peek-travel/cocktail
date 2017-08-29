defmodule CocktailTest do
  use ExUnit.Case
  doctest Cocktail

  alias Cocktail.Schedule

  test "create a schedule with a weekly recurrence rule on specific days AND specific hours" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday, :wednesday, :friday], hours: [10, 12, 14])

    expected = %Cocktail.Schedule{
      start_time: start_time,
      recurrence_rules: [
        %Cocktail.Rule{
          validations: [
            base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
            base_min: [%Cocktail.Validation.ScheduleLock{type: :minute}],
            hour_of_day: [
              %Cocktail.Validation.HourOfDay{hour: 10},
              %Cocktail.Validation.HourOfDay{hour: 12},
              %Cocktail.Validation.HourOfDay{hour: 14}
            ],
            day: [
              %Cocktail.Validation.Day{day: 1},
              %Cocktail.Validation.Day{day: 3},
              %Cocktail.Validation.Day{day: 5}
            ],
            interval: [%Cocktail.Validation.Interval{interval: 1, type: :weekly}]
          ]
        }
      ]
    }

    assert schedule == expected
  end

  test "evaluates weekly recurrence rule with specific days AND specific hours" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday, :wednesday, :friday], hours: [10, 12, 14])

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(6)

    assert times == [
      Timex.parse!("2017-08-14T10:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-14T12:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-14T14:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-16T10:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-16T12:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-16T14:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "create a schedule with a weekly recurrence rule on specific days" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday, :wednesday, :friday])

    expected = %Cocktail.Schedule{
      start_time: start_time,
      recurrence_rules: [
        %Cocktail.Rule{
          validations: [
            base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
            base_min: [%Cocktail.Validation.ScheduleLock{type: :minute}],
            base_hour: [%Cocktail.Validation.ScheduleLock{type: :hour}],
            day: [
              %Cocktail.Validation.Day{day: 1},
              %Cocktail.Validation.Day{day: 3},
              %Cocktail.Validation.Day{day: 5}
            ],
            interval: [%Cocktail.Validation.Interval{interval: 1, type: :weekly}]
          ]
        }
      ]
    }

    assert schedule == expected
  end

  test "evaluates weekly recurrence rule with specific days" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday, :wednesday, :friday])

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(6)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-14T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-16T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-18T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-21T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-23T16:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "create a schedule with a weekly recurrence rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly)

    expected = %Cocktail.Schedule{
      start_time: start_time,
      recurrence_rules: [
        %Cocktail.Rule{
          validations: [
            base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
            base_min: [%Cocktail.Validation.ScheduleLock{type: :minute}],
            base_hour: [%Cocktail.Validation.ScheduleLock{type: :hour}],
            base_wday: [%Cocktail.Validation.ScheduleLock{type: :wday}],
            interval: [%Cocktail.Validation.Interval{interval: 1, type: :weekly}]
          ]
        }
      ]
    }

    assert schedule == expected
  end

  test "evaluates weekly recurrence rule with interval 1" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-18T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-25T16:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates weekly recurrence rule with interval 2" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly, interval: 2)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-25T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-09-08T16:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "create a schedule with a daily recurrence rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily)

    expected = %Cocktail.Schedule{
      start_time: start_time,
      recurrence_rules: [
        %Cocktail.Rule{
          validations: [
            base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
            base_min: [%Cocktail.Validation.ScheduleLock{type: :minute}],
            base_hour: [%Cocktail.Validation.ScheduleLock{type: :hour}],
            interval: [%Cocktail.Validation.Interval{interval: 1, type: :daily}]
          ]
        }
      ]
    }

    assert schedule == expected
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

  test "evaluates daily recurrence rule that ends 3 days later" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")
    until = Timex.parse!("2017-08-14T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:daily, until: until)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(100)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-12T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-13T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-14T16:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "create a schedule with a hourly recurrence rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:hourly)

    expected = %Cocktail.Schedule{
      start_time: start_time,
      recurrence_rules: [
        %Cocktail.Rule{
          validations: [
            base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
            base_min: [%Cocktail.Validation.ScheduleLock{type: :minute}],
            interval: [%Cocktail.Validation.Interval{interval: 1, type: :hourly}]
          ]
        }
      ]
    }

    assert schedule == expected
  end

  test "evaluates hourly recurrence rule with interval 1" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:hourly)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T17:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T18:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates hourly recurrence rule with interval 2" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:hourly, interval: 2)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T18:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T20:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates a schedule with both a hourly(2) and a hourly(3) rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:hourly, interval: 2)
      |> Schedule.add_recurrence_rule(:hourly, interval: 3)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(7)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T18:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T19:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T20:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T22:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-12T00:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-12T01:00:00-07:00", "{ISO:Extended}")
    ]
  end

  test "create a schedule with a minutely recurrence rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely)

    expected = %Cocktail.Schedule{
      start_time: start_time,
      recurrence_rules: [
        %Cocktail.Rule{
          validations: [
            base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
            interval: [%Cocktail.Validation.Interval{interval: 1, type: :minutely}]
          ]
        }
      ]
    }

    assert schedule == expected
  end

  test "evaluates minutely recurrence rule with interval 1" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:01:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:02:00-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates minutely recurrence rule with interval 2" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely, interval: 2)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:02:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:04:00-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates a schedule with both a minutely(2) and a minutely(3) rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:minutely, interval: 2)
      |> Schedule.add_recurrence_rule(:minutely, interval: 3)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(7)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:02:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:03:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:04:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:06:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:08:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:09:00-07:00", "{ISO:Extended}")
    ]
  end

  test "create a schedule with a secondly recurrence rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:secondly)

    expected = %Cocktail.Schedule{
      start_time: start_time,
      recurrence_rules: [
        %Cocktail.Rule{
          validations: [
            interval: [%Cocktail.Validation.Interval{interval: 1, type: :secondly}]
          ]
        }
      ]
    }

    assert schedule == expected
  end

  test "evaluates secondly recurrence rule with interval 1" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:secondly)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:01-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:02-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates secondly recurrence rule with interval 2" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:secondly, interval: 2)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(3)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:02-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:04-07:00", "{ISO:Extended}")
    ]
  end

  test "evaluates a schedule with both a secondly(2) and a secondly(3) rule" do
    start_time = Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}")

    schedule =
      start_time
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:secondly, interval: 2)
      |> Schedule.add_recurrence_rule(:secondly, interval: 3)

    times =
      schedule
      |> Cocktail.Schedule.occurrences
      |> Enum.take(7)

    assert times == [
      Timex.parse!("2017-08-11T16:00:00-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:02-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:03-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:04-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:06-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:08-07:00", "{ISO:Extended}"),
      Timex.parse!("2017-08-11T16:00:09-07:00", "{ISO:Extended}")
    ]
  end
end
