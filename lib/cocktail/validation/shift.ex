defmodule Cocktail.Validation.Shift do
  @moduledoc false

  @type change_type :: :no_change | :updated

  @type result :: {change_type, DateTime.t}

  @typep shift_type :: :days | :hours | :minutes | :seconds

  import Timex, only: [shift: 2, beginning_of_day: 1]

  @spec shift_by(integer, shift_type, DateTime.t) :: result
  def shift_by(0, _, time), do: {:no_change, time}
  def shift_by(amount, type, time), do: {:updated, shift(time, "#{type}": amount)}

  @spec shift_by_bod(integer, shift_type, DateTime.t) :: result
  def shift_by_bod(0, _, time), do: {:no_change, time}
  def shift_by_bod(amount, type, time), do: {:updated, time |> shift("#{type}": amount) |> beginning_of_day()}
end
