defmodule Cocktail.Parser.ICalendar do
  @time_pattern ~r/([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{2})/

  alias Cocktail.Schedule

  @doc ~S"""
  Parses the given `text` in iCalendar format into a Cocktail.Schedule.

  ## Examples

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=DAILY;INTERVAL=2")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
        recurrence_rules: [
          %Cocktail.Rule{
            validations: [
              base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
              base_min: [%Cocktail.Validation.ScheduleLock{type: :minute}],
              base_hour: [%Cocktail.Validation.ScheduleLock{type: :hour}],
              interval: [%Cocktail.Validation.Interval{interval: 2, type: :daily}]
            ]
          }
        ]
      }

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=HOURLY;COUNT=10")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
        recurrence_rules: [
          %Cocktail.Rule{
            count: 10,
            validations: [
              base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
              base_min: [%Cocktail.Validation.ScheduleLock{type: :minute}],
              interval: [%Cocktail.Validation.Interval{interval: 1, type: :hourly}]
            ]
          }
        ]
      }

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=MINUTELY;INTERVAL=30;UNTIL=20170811T230000Z")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
        recurrence_rules: [
          %Cocktail.Rule{
            until: Timex.to_datetime({{2017, 8, 11}, {23, 0, 0}}),
            validations: [
              base_sec: [%Cocktail.Validation.ScheduleLock{type: :second}],
              interval: [%Cocktail.Validation.Interval{interval: 30, type: :minutely}]
            ]
          }
        ]
      }

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=DAILY\nDTEND;TZID=America/Los_Angeles:20170810T170000")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
        duration: 3600,
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

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=WEEKLY")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
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

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
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
  """
  def parse(text) do
    text
    |> String.split("\n")
    |> Enum.reduce(nil, &parse_line/2)
  end

  # parses the first line, because `schedule` is nil at first
  # e.g. "DTSTART;TZID=America/Los_Angeles:20170810T160000"
  #   => %Cocktail.Schedule{start_time: ...}
  defp parse_line("DTSTART;TZID=" <> line, nil) do
    line
    |> parse_time_with_zone()
    |> Cocktail.schedule
  end

  # parses an rrule line and adds it to the schedule
  # e.g. "RRULE:FREQ=DAILY;INTERVAL=2" => %Cocktail.Schedule{..., recurrence_rules: [...]}
  defp parse_line("RRULE:" <> line, schedule) do
    {frequency, options} =
      line
      |> String.split(";")
      |> Enum.map(&parse_rrule_option/1)
      |> Keyword.pop(:frequency)

    Schedule.add_recurrence_rule(schedule, frequency, options)
  end

  # parses dtend line and adds the calculated duration to the schedule
  # e.g. "DTEND;TZID=America/Los_Angeles:20170810T170000" => %Cocktail.Schedule{..., duration: 3600}
  defp parse_line("DTEND;TZID=" <> line, schedule) do
    end_time = parse_time_with_zone(line)
    duration = Timex.diff(end_time, schedule.start_time, :seconds)

    %{ schedule | duration: duration }
  end

  # parses a simple time string into a pair of date/time triplets
  # e.g. "20170810T160000" => {{2017, 8, 10}, {16, 0, 0}}
  defp parse_time(time_string) do
    @time_pattern
    |> Regex.run(time_string)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple
  end

  # parses a simple time string with timezone id into a DateTime struct
  # e.g. "America/Los_Angeles:20170810T160000" => #DateTime<2017-08-10 16:00:00-07:00 PDT America/Los_Angeles>
  defp parse_time_with_zone(time_with_zone_string) do
    [timezone_id, time_string] = String.split(time_with_zone_string, ":")

    time_string
    |> parse_time()
    |> Timex.to_datetime(timezone_id) # TODO: can return AmbiguousDateTime
  end

  # parses an rrule FREQ options
  # e.g. "FREQ=DAILY" => {:frequency, :daily}
  defp parse_rrule_option("FREQ=" <> freq) do
    freq = freq |> String.downcase |> String.to_atom
    {:frequency, freq}
  end

  # parses an rrule INTERVAL option
  # e.g. "INTERVAL=2" => {:interval, 2}
  defp parse_rrule_option("INTERVAL=" <> interval) do
    interval = interval |> String.to_integer
    {:interval, interval}
  end

  # parses an rrule COUNT option
  # e.g. "COUNT=10" => {:count, 10}
  defp parse_rrule_option("COUNT=" <> count) do
    count = count |> String.to_integer
    {:count, count}
  end

  # parses an rrule UNTIL option
  # e.g. "UNTIL=20170811T230000Z" => {:until, #DateTime<2017-08-11 23:00:00Z>}
  defp parse_rrule_option("UNTIL=" <> until) do
    until = until |> parse_time() |> Timex.to_datetime
    {:until, until}
  end

  defp parse_rrule_option("BYDAY=" <> by_days) do
    days = by_days |> String.split(",") |> Enum.map(&day_number/1)
    {:days, days}
  end

  defp day_number("SU"), do: :sunday
  defp day_number("MO"), do: :monday
  defp day_number("TU"), do: :tuesday
  defp day_number("WE"), do: :wednesday
  defp day_number("TH"), do: :thursday
  defp day_number("FR"), do: :friday
  defp day_number("SA"), do: :saturday
end
