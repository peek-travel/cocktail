defmodule Cocktail.RuleState do
  @moduledoc false

  alias Cocktail.{Rule, Validation, Validation.Shift}

  @type t :: %__MODULE__{
          count: pos_integer | nil,
          until: Cocktail.time() | nil,
          validations: [Validation.t(), ...],
          current_time: Cocktail.time() | nil
        }

  @enforce_keys [:validations]
  defstruct count: nil,
            until: nil,
            validations: [],
            current_time: nil

  @validation_order [
    :base_sec,
    :second_of_minute,
    :base_min,
    :minute_of_hour,
    :base_hour,
    :hour_of_day,
    :time_of_day,
    :time_range,
    :base_wday,
    :base_mday,
    :day,
    :day_of_month,
    :interval
  ]

  @spec new(Rule.t()) :: t
  def new(%Rule{} = rule) do
    %__MODULE__{
      count: rule.count,
      until: rule.until,
      validations: rule.validations |> sort_validations()
    }
  end

  @spec sort_validations(Validation.validations_map()) :: [Validation.t(), ...]
  defp sort_validations(validations_map) do
    for key <- @validation_order, validation = validations_map[key], !is_nil(validation) do
      validation
    end
  end

  @spec next_time(t, Cocktail.time(), Cocktail.time()) :: t
  def next_time(%__MODULE__{validations: validations} = rule_state, current_time, start_time) do
    time = do_next_time(validations, current_time, start_time)

    new_state(rule_state, time)
  end

  @spec do_next_time([Validation.t()], Cocktail.time(), Cocktail.time()) :: Cocktail.time()
  defp do_next_time(validations, time, start_time) do
    case Enum.reduce(validations, {:no_change, time}, &next_time_for_validation(&1, &2, start_time)) do
      {:no_change, new_time} ->
        new_time

      {:change, new_time} ->
        do_next_time(validations, new_time, start_time)
    end
  end

  @spec next_time_for_validation(Validation.t(), Shift.result(), Cocktail.time()) :: Shift.result()
  defp next_time_for_validation(%mod{} = validation, {change, time}, start_time) do
    validation
    |> mod.next_time(time, start_time)
    |> mark_change(change)
  end

  @spec new_state(t, Cocktail.time()) :: t
  defp new_state(%__MODULE__{until: nil} = rule_state, time), do: %{rule_state | current_time: time}

  defp new_state(%__MODULE__{until: until} = rule_state, time) do
    if Timex.compare(until, time) == -1 do
      %{rule_state | current_time: nil}
    else
      %{rule_state | current_time: time}
    end
  end

  @spec mark_change(Shift.result(), Shift.change_type()) :: Shift.result()
  defp mark_change({:no_change, time}, :no_change), do: {:no_change, time}
  defp mark_change({:no_change, time}, :change), do: {:change, time}
  defp mark_change({:change, time}, :no_change), do: {:change, time}
  defp mark_change({:change, time}, :change), do: {:change, time}
end
