defmodule Cocktail.Validation.Shift do
  @moduledoc false

  @type change_type :: :no_change | :updated

  @type result :: {change_type, Cocktail.time()}

  @typep shift_type :: :months | :days | :hours | :minutes | :seconds

  @typep option :: nil | :beginning_of_day | :beginning_of_hour | :beginning_of_minute

  import Timex, only: [shift: 2, beginning_of_day: 1]

  @spec shift_by(integer, shift_type, Cocktail.time(), option) :: result
  def shift_by(amount, type, time, option \\ nil)
  def shift_by(0, _, time, _), do: {:no_change, time}

  def shift_by(amount, type, time, option) do
    new_time =
      time
      |> shift("#{type}": amount)
      |> apply_option(option)

    {:change, new_time}
  end

  @spec apply_option(Cocktail.time(), option) :: Cocktail.time()
  defp apply_option(time, nil), do: time
  defp apply_option(time, :beginning_of_day), do: time |> beginning_of_day()
  defp apply_option(time, :beginning_of_hour), do: %{time | minute: 0, second: 0, microsecond: {0, 0}}
  defp apply_option(time, :beginning_of_minute), do: %{time | second: 0, microsecond: {0, 0}}
end
