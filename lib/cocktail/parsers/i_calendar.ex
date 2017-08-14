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
  """
  def parse(text) do
    text
    |> String.split("\n")
    |> Enum.reduce(nil, &parse_line/2)
  end

  # assume the first line is the start time
  defp parse_line(line, nil) do
    # e.g. "DTSTART;TZID=America/Los_Angeles:20170810T160000"
    ["DTSTART", "TZID", timezone_id, start_time_string] = String.split(line, [":", ";", "="])

    start_time_string
    |> parse_time()
    |> Timex.to_datetime(timezone_id)
    |> Cocktail.schedule
  end

  defp parse_line("RRULE:" <> line, schedule) do
    # e.g. "RRULE:FREQ=DAILY;INTERVAL=2"
    options =
      line
      |> String.split(";")
      |> Enum.map(&parse_rrule_option/1)
      |> Keyword.new

    Cocktail.Schedule.add_recurrence_rule(schedule, options)
  end

  defp parse_time(time_string) do
    # e.g. "20170810T160000" => {{2017, 8, 10}, {16, 0, 0}}
    @time_pattern
    |> Regex.run(time_string)
    |> tl()
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(3)
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple
  end

  defp parse_rrule_option("FREQ=" <> freq) do
    # e.g. "FREQ=DAILY" => {:frequency, :daily}
    freq = freq |> String.downcase |> String.to_atom
    {:frequency, freq}
  end

  defp parse_rrule_option("INTERVAL=" <> interval) do
    # e.g. "INTERVAL=2" => {:interval, 2}
    interval = interval |> String.to_integer
    {:interval, interval}
  end
end
