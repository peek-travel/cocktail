defmodule Cocktail.ScheduleState do
  @moduledoc false

  alias Cocktail.{Schedule, RuleState, Span}

  @type t :: %__MODULE__{
              recurrence_rules: [RuleState.t],
              start_time:       DateTime.t,
              current_time:     DateTime.t,
              duration:         pos_integer | nil}

  @enforce_keys [:recurrence_rules, :start_time, :current_time]
  defstruct recurrence_rules: [],
            start_time:       nil,
            current_time:     nil,
            duration:         nil

  # @spec new(Schedule.t, DateTime.t | nil) :: t # TODO: this spec doesn't work for some reason
  def new(%Schedule{} = schedule, nil), do: new(schedule, schedule.start_time)
  def new(%Schedule{} = schedule, current_time) do
    %__MODULE__{
      recurrence_rules: schedule.recurrence_rules |> Enum.map(&RuleState.new/1),
      start_time: schedule.start_time,
      current_time: current_time,
      duration: schedule.duration
    }
  end

  @spec next_time(t) :: { DateTime.t | Span.t, t }
  def next_time(%__MODULE__{} = state) do
    rules_to_keep =
      state.recurrence_rules
      |> Enum.map(&RuleState.next_time(&1, state))
      |> Enum.filter(fn(r) -> !is_nil(r.current_time) end)

    time = min_time_for_rules(rules_to_keep)

    new_state(time, rules_to_keep, state)
  end

  @spec new_state(DateTime.t, [RuleState.t], t) :: { DateTime.t | Span.t, t }
  defp new_state(nil, _, _), do: nil
  defp new_state(time, rules, state) do
    output = span_or_time(time, state.duration)
    new_state = %{ state |
      recurrence_rules: rules,
      current_time: Timex.shift(time, seconds: 1)
    }

    { output, new_state }
  end

  @spec span_or_time(DateTime.t, pos_integer | nil) :: DateTime.t | Span.t
  defp span_or_time(time, nil), do: time
  defp span_or_time(time, duration), do: Span.new(time, Timex.shift(time, seconds: duration))

  @spec min_time_for_rules([RuleState.t]) :: DateTime.t | nil
  defp min_time_for_rules([]), do: nil
  defp min_time_for_rules(rules) do
    rules
    |> Enum.min_by(fn(r) -> Timex.to_unix(r.current_time) end, fn -> nil end)
    |> Map.get(:current_time)
  end
end
