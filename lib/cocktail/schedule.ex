defmodule Cocktail.Schedule do
  defstruct [ :recurrence_rules, :start_time, :duration ]

  alias Cocktail.{Rule, Span}
  alias Cocktail.Parser.ICalendar

  def new(start_time, options \\ []) do
    %__MODULE__{ recurrence_rules: [], start_time: start_time, duration: options[:duration] }
  end

  def from_i_calendar(text) do
    ICalendar.parse(text)
  end

  def add_recurrence_rule(schedule, frequency, options \\ []) do
    %{ schedule | recurrence_rules: [Rule.new(frequency, options) | schedule.recurrence_rules] }
  end

  def occurrences(%__MODULE__{} = schedule, start_time \\ nil) do
    start_time = start_time || schedule.start_time
    Stream.unfold({ schedule, start_time }, &next_time/1)
  end

  defp next_time({ %__MODULE__{} = schedule, time }) do
    time =
      schedule.recurrence_rules
      |> Enum.map(&Rule.next_time(&1, time, schedule.start_time))
      |> Enum.min

    output = span_or_time(time, schedule.duration)

    { output, { schedule, Timex.shift(time, seconds: 1) } }
  end

  defp span_or_time(time, nil), do: time
  defp span_or_time(time, duration), do: Span.new(time, Timex.shift(time, seconds: duration))
end

