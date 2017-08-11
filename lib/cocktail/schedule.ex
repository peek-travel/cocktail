defmodule Cocktail.Schedule do
  defstruct [ recurrence_rules: [], start_time: nil ]

  alias Cocktail.Rules

  def new(start_time) do
    %__MODULE__{ start_time: start_time }
  end

  def add_recurrence_rule(%__MODULE__{ recurrence_rules: recurrence_rules } = schedule, :daily) do
    %{ schedule | recurrence_rules: recurrence_rules ++ [Rules.daily] }
  end

  def occurrences(%__MODULE__{ start_time: schedule_start_time } = schedule, start_time \\ nil) do
    start_time = start_time || schedule_start_time
    Stream.unfold({ schedule, start_time, start_time }, &next_time/1)
  end

  def next_time({ %__MODULE__{ recurrence_rules: recurrence_rules } = schedule, start_time, time }) do
    time =
      recurrence_rules
      |> Enum.map(&Rules.next_time(&1, start_time, time))
      |> Enum.min

    { time, { schedule, start_time, Timex.shift(time, seconds: 1) } }
  end
end
