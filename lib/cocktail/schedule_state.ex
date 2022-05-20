defmodule Cocktail.ScheduleState do
  @moduledoc false

  alias Cocktail.{RuleState, Schedule, Span}

  @type t :: %__MODULE__{
          recurrence_rules: [RuleState.t()],
          recurrence_times: [Cocktail.time()],
          exception_times: [Cocktail.time()],
          start_time: Cocktail.time(),
          current_time: Cocktail.time(),
          duration: pos_integer | nil
        }

  @enforce_keys [:start_time, :current_time]
  defstruct recurrence_rules: [],
            recurrence_times: [],
            exception_times: [],
            start_time: nil,
            current_time: nil,
            duration: nil

  @spec new(Schedule.t(), Cocktail.time() | nil) :: t
  def new(%Schedule{} = schedule, nil), do: new(schedule, schedule.start_time)

  def new(%Schedule{} = schedule, current_time) do
    current_time =
      if Timex.compare(current_time, schedule.start_time) < 0,
        do: schedule.start_time,
        else: current_time

    recurrence_times_after_current_time =
      schedule.recurrence_times
      |> Enum.filter(&(Timex.compare(&1, current_time) >= 0))
      |> Enum.sort(&(Timex.compare(&1, &2) <= 0))

    %__MODULE__{
      recurrence_rules: schedule.recurrence_rules |> Enum.map(&RuleState.new/1),
      recurrence_times: recurrence_times_after_current_time,
      exception_times:
        schedule.exception_times |> Enum.sort(&(Timex.compare(&1, &2) <= 0)) |> Enum.uniq(),
      start_time: schedule.start_time,
      current_time: current_time,
      duration: schedule.duration
    }
    |> at_least_one_time()
  end

  @spec next_time(t) :: {Cocktail.occurrence(), t}
  def next_time(%__MODULE__{} = state) do
    {time, remaining_rules} = next_time_from_recurrence_rules(state)
    {time, remaining_times} = next_time_from_recurrence_times(state.recurrence_times, time)
    {is_exception, remaining_exceptions} = apply_exception_time(state.exception_times, time)

    result =
      next_occurrence_and_state(
        time,
        remaining_rules,
        remaining_times,
        remaining_exceptions,
        state
      )

    case result do
      {occurrence, state} ->
        if is_exception do
          next_time(state)
        else
          {occurrence, state}
        end

      nil ->
        nil
    end
  end

  @spec next_time_from_recurrence_rules(t) :: {Cocktail.time() | nil, [RuleState.t()]}
  defp next_time_from_recurrence_rules(state) do
    remaining_rules =
      state.recurrence_rules
      |> Enum.map(&RuleState.next_time(&1, state.current_time, state.start_time))
      |> Enum.filter(fn r -> !is_nil(r.current_time) end)

    time = min_time_for_rules(remaining_rules)

    {time, remaining_rules}
  end

  @spec next_time_from_recurrence_times([Cocktail.time()], Cocktail.time() | nil) ::
          {Cocktail.time() | nil, [Cocktail.time()]}
  defp next_time_from_recurrence_times([], current_time), do: {current_time, []}
  defp next_time_from_recurrence_times([next_time | rest], nil), do: {next_time, rest}

  defp next_time_from_recurrence_times([next_time | rest] = times, current_time) do
    if Timex.compare(next_time, current_time) <= 0 do
      {next_time, rest}
    else
      {current_time, times}
    end
  end

  @spec apply_exception_time([Cocktail.time()], Cocktail.time() | nil) ::
          {boolean, [Cocktail.time()]}
  defp apply_exception_time([], _), do: {false, []}
  defp apply_exception_time(exceptions, nil), do: {false, exceptions}

  defp apply_exception_time([next_exception | rest] = exceptions, current_time) do
    case Timex.compare(next_exception, current_time) do
      0 ->
        {true, rest}

      -1 ->
        apply_exception_time(rest, current_time)

      _ ->
        {false, exceptions}
    end
  end

  @spec next_occurrence_and_state(
          Cocktail.time(),
          [RuleState.t()],
          [Cocktail.time()],
          [Cocktail.time()],
          t
        ) ::
          {Cocktail.occurrence(), t} | nil
  defp next_occurrence_and_state(nil, _, _, _, _), do: nil

  defp next_occurrence_and_state(time, rules, times, exceptions, state) do
    occurrence = span_or_time(time, state.duration)

    new_state = %{
      state
      | recurrence_rules: rules,
        recurrence_times: times,
        exception_times: exceptions,
        current_time: Timex.shift(time, seconds: 1)
    }

    {occurrence, new_state}
  end

  @spec span_or_time(Cocktail.time() | nil, pos_integer | nil) :: Cocktail.occurrence()
  defp span_or_time(time, nil), do: time
  defp span_or_time(time, duration), do: Span.new(time, Timex.shift(time, seconds: duration))

  @spec min_time_for_rules([RuleState.t()]) :: Cocktail.time() | nil
  defp min_time_for_rules([]), do: nil
  defp min_time_for_rules([rule]), do: rule.current_time

  defp min_time_for_rules(rules) do
    rules
    |> Enum.min_by(&Timex.to_erl(&1.current_time))
    |> Map.get(:current_time)
  end

  @spec at_least_one_time(t) :: t
  def at_least_one_time(%__MODULE__{recurrence_rules: [], recurrence_times: []} = state),
    do: %{state | recurrence_times: [state.start_time]}

  def at_least_one_time(%__MODULE__{} = state), do: state
end
