defmodule Cocktail.Parser.ICalendar do
  @time_pattern ~r/([0-9]{4})([0-9]{2})([0-9]{2})T([0-9]{2})([0-9]{2})([0-9]{2})/

  alias Cocktail.Schedule

  @doc ~S"""
  Parses the given `i_calendar_string` in iCalendar format into a `Cocktail.Schedule`.

  ## Examples

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=DAILY;INTERVAL=2")
      #Cocktail.Schedule<Every 2 days>

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=WEEKLY")
      #Cocktail.Schedule<Weekly>

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=WEEKLY;BYDAY=MO,WE,FR")
      #Cocktail.Schedule<Weekly on Mondays, Wednesdays and Fridays>

      iex> parse("DTSTART;TZID=America/Los_Angeles:20170810T160000\nRRULE:FREQ=WEEKLY;INTERVAL=2;BYDAY=MO,WE,FR;BYHOUR=10,12,14")
      #Cocktail.Schedule<Every 2 weeks on Mondays, Wednesdays and Fridays on the 10th, 12th and 14th hours of the day>
  """
  def parse(i_calendar_string) do
    i_calendar_string
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
    options =
      line
      |> String.split(";")
      |> Enum.map(&parse_rrule_option/1)

    Schedule.add_recurrence_rule(schedule, options)
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

  # parses an rrule BYDAY option
  # e.g. "BYDAY=MO,WE,FR" => {:days, [:monday, :wednesday, :friday]}
  defp parse_rrule_option("BYDAY=" <> by_days) do
    days = by_days |> String.split(",") |> Enum.map(&day_atom/1)
    {:days, days}
  end

  # parses an rrule BYHOUR option
  # e.g. "BYHOUR=10,12,14" => {:hours, [10, 12, 14]}
  defp parse_rrule_option("BYHOUR=" <> by_hours) do
    hours = by_hours |> String.split(",") |> Enum.map(&String.to_integer/1)
    {:hours, hours}
  end

  defp day_atom("SU"), do: :sunday
  defp day_atom("MO"), do: :monday
  defp day_atom("TU"), do: :tuesday
  defp day_atom("WE"), do: :wednesday
  defp day_atom("TH"), do: :thursday
  defp day_atom("FR"), do: :friday
  defp day_atom("SA"), do: :saturday
end
