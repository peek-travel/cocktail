defmodule Cocktail.ScheduleState do
  @moduledoc false

  alias Cocktail.{Schedule, RuleState, Span}

  @type t :: %__MODULE__{
              recurrence_rules: [RuleState.t],
              recurrence_times: [Cocktail.time],
              exception_times:  [Cocktail.time],
              start_time:       Cocktail.time,
              current_time:     Cocktail.time,
              duration:         pos_integer | nil}

  @enforce_keys [:start_time, :current_time]
  defstruct recurrence_rules: [],
            recurrence_times: [],
            exception_times:  [],
            start_time:       nil,
            current_time:     nil,
            duration:         nil

  # @spec new(Schedule.t, Cocktail.time | nil) :: t # FIXME: why doesn't this spec work?
  def new(%Schedule{} = schedule, nil), do: new(schedule, schedule.start_time)
  def new(%Schedule{} = schedule, current_time) do
    %__MODULE__{
      recurrence_rules: schedule.recurrence_rules |> Enum.map(&RuleState.new/1),
      recurrence_times: schedule.recurrence_times |> Enum.sort(&(Timex.compare(&1, &2) <= 0)),
      exception_times: schedule.exception_times |> Enum.sort(&(Timex.compare(&1, &2) <= 0)),
      start_time: schedule.start_time,
      current_time: current_time,
      duration: schedule.duration
    }
  end

  @spec next_time(t) :: {Cocktail.occurrence, t}
  def next_time(%__MODULE__{} = state) do
    {time, rules_to_keep} = next_time_from_recurrence_rules(state)
    {time, times_to_keep} = next_time_from_recurrence_times(state.recurrence_times, time)

    new_state(time, rules_to_keep, times_to_keep, state)
  end

  # TODO: spec
  defp next_time_from_recurrence_rules(state) do
    rules_to_keep =
      state.recurrence_rules
      |> Enum.map(&RuleState.next_time(&1, state))
      |> Enum.filter(fn(r) -> !is_nil(r.current_time) end)

    time = min_time_for_rules(rules_to_keep)

    {time, rules_to_keep}
  end

  # TODO: spec
  defp next_time_from_recurrence_times([], current_time), do: {current_time, []}
  defp next_time_from_recurrence_times([next_time | rest] = times, current_time) do
    if Timex.compare(next_time, current_time) <= 0 do
      {next_time, rest}
    else
      {current_time, times}
    end
  end

  @spec new_state(Cocktail.time, [RuleState.t], [Cocktail.time], t) :: {Cocktail.occurrence, t}
  defp new_state(nil, _, _, _), do: nil
  defp new_state(time, rules, times, state) do
    output = span_or_time(time, state.duration)
    new_state = %{state |
      recurrence_rules: rules,
      recurrence_times: times,
      current_time: Timex.shift(time, seconds: 1)
    }

    {output, new_state}
  end

  @spec span_or_time(Cocktail.time, pos_integer | nil) :: Cocktail.occurrence
  defp span_or_time(time, nil), do: time
  defp span_or_time(time, duration), do: Span.new(time, Timex.shift(time, seconds: duration))

  @spec min_time_for_rules([RuleState.t]) :: Cocktail.time | nil
  defp min_time_for_rules([]), do: nil
  defp min_time_for_rules(rules) do
    rules
    |> Enum.min_by(fn(r) -> Timex.to_unix(r.current_time) end, fn -> nil end)
    |> Map.get(:current_time)
  end
end
