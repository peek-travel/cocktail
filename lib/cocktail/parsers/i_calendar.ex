defmodule Cocktail.Parsers.ICalendar do
  @time_pattern ~r/([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{2})/

  @doc ~S"""
  Parses the given `text` in iCalendar format into a Cocktail.Schedule.

  ## Examples

      iex> Cocktail.Parsers.ICalendar.parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=DAILY;INTERVAL=2")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
        recurrence_rules: [%Cocktail.Rules.Daily{interval: 2}]
      }

      iex> Cocktail.Parsers.ICalendar.parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=HOURLY;COUNT=10")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
        recurrence_rules: [%Cocktail.Rules.Hourly{interval: 1, count: 10}]
      }

      iex> Cocktail.Parsers.ICalendar.parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=MINUTELY;INTERVAL=30;UNTIL=20170811T230000Z")
      %Cocktail.Schedule{
        start_time: Timex.to_datetime({{2017, 8, 10}, {16, 0, 0}}, "America/Los_Angeles"),
        recurrence_rules: [%Cocktail.Rules.Minutely{interval: 30, until: Timex.to_datetime({{2017, 8, 11}, {23, 0, 0}})}]
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
  defp parse_line(line, nil) do
    ["DTSTART", "TZID", timezone_id, start_time_string] = String.split(line, [":", ";", "="])

    start_time_string
    |> parse_time()
    |> Timex.to_datetime(timezone_id)
    |> Cocktail.schedule
  end

  # parses an rrule line and adds it to the schedule
  # e.g. "RRULE:FREQ=DAILY;INTERVAL=2" => %Cocktail.Schedule{..., recurrence_rules: [...]}
  defp parse_line("RRULE:" <> line, schedule) do
    options =
      line
      |> String.split(";")
      |> Enum.map(&parse_rrule_option/1)
      |> Keyword.new

    Cocktail.Schedule.add_recurrence_rule(schedule, options)
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
end
