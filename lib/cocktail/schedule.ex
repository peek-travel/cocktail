defmodule Cocktail.Schedule do
  defstruct [ :recurrence_rules, :start_time, :duration ]

  alias Cocktail.{Rules, Span}
  alias Cocktail.Parsers.ICalendar

  def new(start_time, options \\ []) do
    duration = Keyword.get(options, :duration)
    %__MODULE__{ recurrence_rules: [], start_time: start_time, duration: duration }
  end

  def from_i_calendar(text) do
    ICalendar.parse(text)
  end

  def add_recurrence_rule(schedule, options) when is_list(options) do
    type = Keyword.get(options, :frequency)
    add_recurrence_rule(schedule, type, options)
  end

  def add_recurrence_rule(schedule, type, options \\ [])

  def add_recurrence_rule(%__MODULE__{} = schedule, :daily, options) do
    %{ schedule | recurrence_rules: schedule.recurrence_rules ++ [Rules.daily(options)] }
  end

  def add_recurrence_rule(%__MODULE__{} = schedule, :hourly, options) do
    %{ schedule | recurrence_rules: schedule.recurrence_rules ++ [Rules.hourly(options)] }
  end

  def add_recurrence_rule(%__MODULE__{} = schedule, :minutely, options) do
    %{ schedule | recurrence_rules: schedule.recurrence_rules ++ [Rules.minutely(options)] }
  end

  def add_recurrence_rule(%__MODULE__{} = schedule, :secondly, options) do
    %{ schedule | recurrence_rules: schedule.recurrence_rules ++ [Rules.secondly(options)] }
  end

  def occurrences(%__MODULE__{} = schedule, start_time \\ nil) do
    start_time = start_time || schedule.start_time
    Stream.unfold({ schedule, start_time }, &next_time/1)
  end

  def next_time({ %__MODULE__{} = schedule, time }) do
    time =
      schedule.recurrence_rules
      |> Enum.map(&Rules.next_time(&1, schedule.start_time, time))
      |> Enum.min

    output = span_or_time(time, schedule.duration)

    { output, { schedule, Timex.shift(time, seconds: 1) } }
  end

  defp span_or_time(time, nil), do: time
  defp span_or_time(time, duration) do # TODO: don't assume seconds
    Span.new(time, Timex.shift(time, seconds: duration))
  end
end

