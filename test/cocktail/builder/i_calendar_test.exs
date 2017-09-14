defmodule Cocktail.Builder.ICalendarTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  import Cocktail.TestSupport.DateTimeSigil

  doctest Cocktail.Builder.ICalendar, import: true

  test "build a schedule with a duration" do
    schedule = Cocktail.schedule(~N[2017-01-01 09:00:00], duration: 3_600)
    i_calendar_string = Schedule.to_i_calendar(schedule)

    assert i_calendar_string == """
                                DTSTART:20170101T090000
                                DTEND:20170101T100000\
                                """
  end

  test "build a schedule with timezone with until option" do
    schedule =
      ~Y[2017-01-01 09:00:00 America/Los_Angeles]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, until: ~Y[2017-01-31 09:00:00 America/Los_Angeles])

      i_calendar_string = Schedule.to_i_calendar(schedule)

    assert i_calendar_string == """
                                DTSTART;TZID=America/Los_Angeles:20170101T090000
                                RRULE:FREQ=DAILY;UNTIL=20170131T170000Z\
                                """
  end

  test "build a schedule with a BYDAY option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:weekly, days: [:monday, :wednesday, :friday])

    i_calendar_string = Schedule.to_i_calendar(schedule)

    assert i_calendar_string == """
                                DTSTART:20170101T090000
                                RRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR\
                                """
  end

  test "build a schedule with a BYHOUR option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, hours: [10, 12, 14])

    i_calendar_string = Schedule.to_i_calendar(schedule)

    assert i_calendar_string == """
                                DTSTART:20170101T090000
                                RRULE:FREQ=DAILY;BYHOUR=10,12,14\
                                """
  end

  test "build a schedule with a BYMINUTE option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, minutes: [0, 15, 30, 45])

    i_calendar_string = Schedule.to_i_calendar(schedule)

    assert i_calendar_string == """
                                DTSTART:20170101T090000
                                RRULE:FREQ=DAILY;BYMINUTE=0,15,30,45\
                                """
  end

  test "build a schedule with a BYSECOND option" do
    schedule =
      ~N[2017-01-01 09:00:00]
      |> Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily, seconds: [0, 30])

    i_calendar_string = Schedule.to_i_calendar(schedule)

    assert i_calendar_string == """
                                DTSTART:20170101T090000
                                RRULE:FREQ=DAILY;BYSECOND=0,30\
                                """
  end
end
