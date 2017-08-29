defmodule Cocktail.ScheduleState do
  alias Cocktail.{Schedule, RuleState, Span}

  defstruct [:recurrence_rules, :start_time, :current_time, :duration]

  def new(%Schedule{} = schedule, nil), do: new(schedule, schedule.start_time)
  def new(%Schedule{} = schedule, current_time) do
    %__MODULE__{
      recurrence_rules: schedule.recurrence_rules |> Enum.map(&RuleState.new/1),
      start_time: schedule.start_time,
      current_time: current_time,
      duration: schedule.duration
    }
  end

  def next_time(%__MODULE__{} = state) do
    rules_to_keep =
      state.recurrence_rules
      |> Enum.map(&RuleState.next_time(&1, state))
      |> Enum.filter(fn(r) -> !is_nil(r.current_time) end)

    time = min_time_for_rules(rules_to_keep)

    new_state(time, rules_to_keep, state)
  end

  defp new_state(nil, _, _), do: nil
  defp new_state(time, rules, state) do
    output = span_or_time(time, state.duration)
    new_state = %{ state |
      recurrence_rules: rules,
      current_time: Timex.shift(time, seconds: 1)
    }

    { output, new_state }
  end

  defp span_or_time(nil, _), do: nil
  defp span_or_time(time, nil), do: time
  defp span_or_time(time, duration), do: Span.new(time, Timex.shift(time, seconds: duration))

  defp min_time_for_rules([]), do: nil
  defp min_time_for_rules(rules) do
    rules
    |> Enum.min_by(fn(r) -> Timex.to_unix(r.current_time) end, fn -> nil end)
    |> Map.get(:current_time)
  end
end
