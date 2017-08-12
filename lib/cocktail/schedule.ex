defmodule Cocktail.Schedule do
  defstruct [ recurrence_rules: [], start_time: nil ]

  alias Cocktail.Rules

  def new(start_time) do
    %__MODULE__{ start_time: start_time }
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

    { time, { schedule, Timex.shift(time, seconds: 1) } }
  end
end
