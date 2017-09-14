defmodule Cocktail.Parser.JSONTest do
  use ExUnit.Case

  alias Cocktail.Rule
  alias Cocktail.Validation.{Interval, Day, HourOfDay, MinuteOfHour, SecondOfMinute}

  import Cocktail.Parser.JSON
  import Cocktail.TestSupport.DateTimeSigil

  doctest Cocktail.Parser.JSON, import: true

  test "parse an empty schedule" do
    empty_schedule_json_string = "{\"start_time\": {\"time\": \"2017-01-01 06:00:00\", \"zone\": \"America/Los_Angeles\"}}"
    assert {:ok, schedule} = parse(empty_schedule_json_string)
    assert schedule.start_time == ~Y[2017-01-01 06:00:00 America/Los_Angeles]
  end

  test "parse a pre-parsed map" do
    empty_schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      }
    }
    assert {:ok, schedule} = parse_map(empty_schedule_map)
    assert schedule.start_time == ~Y[2017-01-01 06:00:00 America/Los_Angeles]
  end

  test "parse a schedule with a naive time" do
    empty_schedule_map = %{"start_time" => "2017-01-01 06:00:00"}
    assert {:ok, schedule} = parse_map(empty_schedule_map)
    assert schedule.start_time == ~N[2017-01-01 06:00:00]
  end

  test "parse a missing duration" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "duration" => nil
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert schedule.duration == nil
  end

  test "parse a schedule with a duration" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "duration" => 3600
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert schedule.duration == 3600
  end

  test "parse a schedule with a missing rules list" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => nil
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert schedule.recurrence_rules == []
  end

  test "parse a schedule with an empty rules list" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => []
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert schedule.recurrence_rules == []
  end

  for frequency <- [:weekly, :daily, :hourly, :minutely, :secondly] do
    test "parse a schedule with a single #{frequency} repeat rule" do
      schedule_map = %{
        "start_time" => %{
          "time" => "2017-01-01 06:00:00",
          "zone" => "America/Los_Angeles"
        },
        "recurrence_rules" => [ %{ "frequency" => "#{unquote(frequency)}", "interval" => 1 } ]
      }
      assert {:ok, schedule} = parse_map(schedule_map)
      assert [ %Rule{} = rule ] = schedule.recurrence_rules
      assert rule.validations[:interval] == [ %Interval{type: unquote(frequency), interval: 1} ]
    end
  end

  test "parse a schedule with a single weekly repeat rule, with empty days of the week specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "days" => []
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_wday] != nil
    assert rule.validations[:day] == nil
  end

  test "parse a schedule with a single weekly repeat rule, with days of the week specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "days" => ["monday", "wednesday", "friday"]
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_wday] == nil
    assert rule.validations[:day] == [ %Day{day: 1}, %Day{day: 3}, %Day{day: 5} ]
  end

  test "parse a schedule with a single weekly repeat rule, with empty hours of day specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "hours" => []
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_hour] != nil
    assert rule.validations[:hour_of_day] == nil
  end

  test "parse a schedule with a single weekly repeat rule, with hours of the day specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "hours" => [10, 12, 14]
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_hour] == nil
    assert rule.validations[:hour_of_day] == [ %HourOfDay{hour: 10}, %HourOfDay{hour: 12}, %HourOfDay{hour: 14} ]
  end

  test "parse a schedule with a rule that has an until option" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "until" => %{
            "time" => "2017-01-31 06:00:00",
            "zone" => "America/Los_Angeles"
          }
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.until == ~Y[2017-01-31 06:00:00 America/Los_Angeles]
  end

  test "parse a schedule with a single weekly repeat rule, with empty minutes of the hour specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "minutes" => []
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_min] != nil
    assert rule.validations[:minute_of_hour] == nil
  end

  test "parse a schedule with a single weekly repeat rule, with hours of the day and minutes of the hour specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "hours" => [10, 12, 14],
          "minutes" => [0, 15, 30, 45]
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_hour] == nil
    assert rule.validations[:hour_of_day] == [ %HourOfDay{hour: 10}, %HourOfDay{hour: 12}, %HourOfDay{hour: 14} ]
    assert rule.validations[:base_minute] == nil
    assert rule.validations[:minute_of_hour] == [ %MinuteOfHour{minute: 0}, %MinuteOfHour{minute: 15}, %MinuteOfHour{minute: 30}, %MinuteOfHour{minute: 45} ]
  end

  test "parse a schedule with a single weekly repeat rule, with empty seconds of the minute specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "seconds" => []
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_sec] != nil
    assert rule.validations[:second_of_minute] == nil
  end

  test "parse a schedule with a single weekly repeat rule, with hours of the day, minutes of the hour, and seconds of the minute specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "hours" => [10, 12, 14],
          "minutes" => [0, 15, 30, 45],
          "seconds" => [0, 30]
        }
      ]
    }
    assert {:ok, schedule} = parse_map(schedule_map)
    assert [ %Rule{} = rule ] = schedule.recurrence_rules
    assert rule.validations[:base_hour] == nil
    assert rule.validations[:hour_of_day] == [ %HourOfDay{hour: 10}, %HourOfDay{hour: 12}, %HourOfDay{hour: 14} ]
    assert rule.validations[:base_minute] == nil
    assert rule.validations[:minute_of_hour] == [ %MinuteOfHour{minute: 0}, %MinuteOfHour{minute: 15}, %MinuteOfHour{minute: 30}, %MinuteOfHour{minute: 45} ]
    assert rule.validations[:base_second] == nil
    assert rule.validations[:second_of_minute] == [ %SecondOfMinute{second: 0}, %SecondOfMinute{second: 30} ]
  end

  ##########
  # Errors #
  ##########

  test "parse an empty string" do
    assert {:error, {:invalid_json, _}} = parse("")
  end

  test "parse an invalid json string" do
    assert {:error, {:invalid_json, _}} = parse("invalid")
  end

  test "parse an empty object" do
    assert {:error, :missing_start_time} = parse("{}")
  end

  test "parse a null start time" do
    assert {:error, :invalid_time_format} = parse("{\"start_time\": null}")
  end

  test "parse an invalid start time" do
    assert {:error, :invalid_time_format} = parse("{\"start_time\": \"invalid\"}")
  end

  test "parse an invalid duration" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "duration" => "invalid"
    }
    assert {:error, :invalid_duration} = parse_map(schedule_map)
  end

  test "parse a schedule with an invalid rule" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [ "invalid" ]
    }
    assert {:error, {:invalid_rule, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with empty invalid rule map" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [ %{} ]
    }
    assert {:error, {:missing_frequency, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a rule with an invalid frequency" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [ %{"frequency" => "quarterly"} ]
    }
    assert {:error, {:invalid_frequency, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a rule with an invalid interval" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [ %{"frequency" => "daily", "interval" => "invalid"} ]
    }
    assert {:error, {:invalid_interval, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a single weekly repeat rule, with invalid days of the week specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "days" => "invalid"
        }
      ]
    }
    assert {:error, {:invalid_days, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a single weekly repeat rule, with days of the week specified, but containing an invalid day" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "days" => ["invalid"]
        }
      ]
    }
    assert {:error, {:invalid_day, 0}} = parse_map(schedule_map)
  end



  test "parse a schedule with a single weekly repeat rule, with invalid hours of the day specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "hours" => "invalid"
        }
      ]
    }
    assert {:error, {:invalid_hours, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a single weekly repeat rule, with hours of the day specified, but containing an invalid hour" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "hours" => ["invalid"]
        }
      ]
    }
    assert {:error, {:invalid_hour, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a rule that has an invalid until option" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "until" => %{ "foo" => "bar" }
        }
      ]
    }
    assert {:error, {:invalid_time_format, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with one valid rule and one invalid rule" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{ "frequency" => "daily", "interval" => 1 },
        "invalid"
      ]
    }
    assert {:error, {:invalid_rule, 1}} = parse_map(schedule_map)
  end

  test "parse a schedule with a single weekly repeat rule, with invalid minutes of the hour specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "minutes" => "invalid"
        }
      ]
    }
    assert {:error, {:invalid_minutes, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a single weekly repeat rule, with minutes of the hour specified, but containing an invalid minute" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "minutes" => ["invalid"]
        }
      ]
    }
    assert {:error, {:invalid_minute, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a single weekly repeat rule, with invalid seconds of the minute specified" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "seconds" => "invalid"
        }
      ]
    }
    assert {:error, {:invalid_seconds, 0}} = parse_map(schedule_map)
  end

  test "parse a schedule with a single weekly repeat rule, with seconds of the minute specified, but containing an invalid second" do
    schedule_map = %{
      "start_time" => %{
        "time" => "2017-01-01 06:00:00",
        "zone" => "America/Los_Angeles"
      },
      "recurrence_rules" => [
        %{
          "frequency" => "weekly",
          "interval" => 1,
          "seconds" => ["invalid"]
        }
      ]
    }
    assert {:error, {:invalid_second, 0}} = parse_map(schedule_map)
  end
end
