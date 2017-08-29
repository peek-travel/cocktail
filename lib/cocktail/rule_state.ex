defmodule Cocktail.RuleState do
  alias Cocktail.{Rule, Validation, ScheduleState}

  defstruct [:count, :until, :validations, :current_time]

  def new(%Rule{} = rule) do
    %__MODULE__{
      count: rule.count,
      until: rule.until,
      validations: rule.validations
    }
  end

  def next_time(%__MODULE__{} = rule_state, %ScheduleState{} = schedule_state) do
    time = Enum.reduce(rule_state.validations, schedule_state.current_time, &do_next_time(&1, &2, schedule_state.start_time))
    new_state(rule_state, time)
  end

  defp do_next_time({ _, validations }, time, start_time) do
    validations
    |> Enum.map(&Validation.next_time(&1, time, start_time))
    |> Enum.min_by(&Timex.to_unix/1, fn -> nil end)
  end

  defp new_state(%__MODULE__{ until: nil } = rule_state, time), do: %{rule_state | current_time: time}
  defp new_state(%__MODULE__{ until: until } = rule_state, time) do
    if Timex.compare(until, time) == -1 do
      %{rule_state | current_time: nil}
    else
      %{rule_state | current_time: time}
    end
  end
end
