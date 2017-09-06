defmodule Cocktail.RuleState do
  @moduledoc false

  alias Cocktail.{Rule, ScheduleState, Validation}
  alias Cocktail.Validation.Shift

  @type grouped_validations :: [[Validation.t, ...], ...]

  @type t :: %__MODULE__{
              count:             pos_integer | nil,
              until:             DateTime.t | nil,
              validation_groups: grouped_validations,
              current_time:      DateTime.t | nil}

  @enforce_keys [:validation_groups]
  defstruct count:             nil,
            until:             nil,
            validation_groups: [],
            current_time:      nil

  @validation_order [:base_sec, :base_min, :base_hour, :hour_of_day, :base_wday, :day, :interval]

  @spec new(Rule.t) :: t
  def new(%Rule{} = rule) do
    %__MODULE__{
      count: rule.count,
      until: rule.until,
      validation_groups: rule.validations |> sort_and_group_validations()
    }
  end

  @spec sort_and_group_validations(Validation.validations_map) :: grouped_validations
  defp sort_and_group_validations(validations_map) do
    for key <- @validation_order,
        validations = validations_map[key],
        is_list(validations)
    do
      validations
    end
  end

  @spec next_time(t, ScheduleState.t) :: t
  def next_time(%__MODULE__{} = rule_state, %ScheduleState{} = schedule_state) do
    time = do_next_time(rule_state.validation_groups, schedule_state.current_time, schedule_state.start_time)
    new_state(rule_state, time)
  end

  @spec do_next_time(grouped_validations, DateTime.t, DateTime.t) :: DateTime.t
  defp do_next_time(validation_groups, time, start_time) do
    case Enum.reduce(validation_groups, {:no_change, time}, &next_time_for_validations(&1, &2, start_time)) do
      {:no_change, new_time} ->
        new_time
      {:updated, new_time} ->
        do_next_time(validation_groups, new_time, start_time)
    end
  end

  @spec next_time_for_validations([Validation.t], Shift.result, DateTime.t) :: Shift.result
  defp next_time_for_validations(validations, {change, time}, start_time) do
    validations
    |> Enum.map(&next_time_for_validation(&1, time, start_time))
    |> Enum.min_by(fn({_, time}) -> Timex.to_unix(time) end, fn -> nil end)
    |> mark_change(change)
  end

  @spec next_time_for_validation(Validation.t, DateTime.t, DateTime.t) :: Shift.result
  defp next_time_for_validation(%mod{} = validation, time, start_time) do
    mod.next_time(validation, time, start_time)
  end

  @spec new_state(t, DateTime.t) :: t
  defp new_state(%__MODULE__{until: nil} = rule_state, time), do: %{rule_state | current_time: time}
  defp new_state(%__MODULE__{until: until} = rule_state, time) do
    if Timex.compare(until, time) == -1 do
      %{rule_state | current_time: nil}
    else
      %{rule_state | current_time: time}
    end
  end

  @spec mark_change(Shift.result, Shift.change_type) :: Shift.result
  defp mark_change({:no_change, time}, :no_change), do: {:no_change, time}
  defp mark_change({:no_change, time}, :updated), do: {:updated, time}
  defp mark_change({:updated, time}, :no_change), do: {:updated, time}
  defp mark_change({:updated, time}, :updated), do: {:updated, time}
end
