defmodule Cocktail.Schedule do
  defstruct [ :recurrence_rules, :start_time, :duration ]

  alias Cocktail.{Rule, ScheduleState}
  alias Cocktail.Parser.ICalendar

  def new(start_time, options \\ []) do
    %__MODULE__{ recurrence_rules: [], start_time: start_time, duration: options[:duration] }
  end

  def from_i_calendar(text) do
    ICalendar.parse(text)
  end

  def add_recurrence_rule(%__MODULE__{} = schedule, %Rule{} = rule) do
    %{ schedule | recurrence_rules: [rule | schedule.recurrence_rules] }
  end
  def add_recurrence_rule(%__MODULE__{} = schedule, options) when is_list(options) do
    {frequency, options} = Keyword.pop(options, :frequency)
    add_recurrence_rule(schedule, frequency, options)
  end
  def add_recurrence_rule(%__MODULE__{} = schedule, frequency, options \\ []) do
    %{ schedule | recurrence_rules: [Rule.new(frequency, options) | schedule.recurrence_rules] }
  end

  def occurrences(%__MODULE__{} = schedule, start_time \\ nil) do
    schedule
    |> ScheduleState.new(start_time)
    |> Stream.unfold(&ScheduleState.next_time/1)
  end
end
