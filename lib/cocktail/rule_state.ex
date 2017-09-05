defmodule Cocktail.RuleState do
  @moduledoc false

  alias Cocktail.{Rule, ScheduleState}

  defstruct [:count, :until, :validation_groups, :current_time]

  @validation_order [:base_sec, :base_min, :base_hour, :hour_of_day, :base_wday, :day, :interval]

  def new(%Rule{} = rule) do
    %__MODULE__{
      count: rule.count,
      until: rule.until,
      validation_groups: rule.validations |> sort_and_group_validations()
    }
  end

  defp sort_and_group_validations(validations_map) do
    for key <- @validation_order,
        validations = validations_map[key],
        is_list(validations)
    do
      validations
    end
  end

  def next_time(%__MODULE__{} = rule_state, %ScheduleState{} = schedule_state) do
    time = do_next_time(rule_state.validation_groups, schedule_state.current_time, schedule_state.start_time)
    new_state(rule_state, time)
  end

  defp do_next_time(validation_groups, time, start_time) do
    case Enum.reduce(validation_groups, {:no_change, time}, &next_time_for_validations(&1, &2, start_time)) do
      {:no_change, new_time} ->
        new_time
      {:updated, new_time} ->
        do_next_time(validation_groups, new_time, start_time)
    end
  end

  defp next_time_for_validations(validations, {change, time}, start_time) do
    validations
    |> Enum.map(&next_time_for_validation(&1, time, start_time))
    |> Enum.min_by(fn({_, time}) -> Timex.to_unix(time) end, fn -> nil end)
    |> mark_change(change)
  end

  defp next_time_for_validation(%mod{} = validation, time, start_time) do
    mod.next_time(validation, time, start_time)
  end

  defp new_state(%__MODULE__{ until: nil } = rule_state, time), do: %{rule_state | current_time: time}
  defp new_state(%__MODULE__{ until: until } = rule_state, time) do
    if Timex.compare(until, time) == -1 do
      %{rule_state | current_time: nil}
    else
      %{rule_state | current_time: time}
    end
  end

  # this is basically "OR"
  # no_change == false
  # updated == true
  defp mark_change({:no_change, time}, :no_change), do: {:no_change, time}
  defp mark_change({:no_change, time}, :updated), do: {:updated, time}
  defp mark_change({:updated, time}, :no_change), do: {:updated, time}
  defp mark_change({:updated, time}, :updated), do: {:updated, time}
end
