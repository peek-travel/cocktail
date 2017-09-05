defmodule Cocktail.Validation.Shift do
  @moduledoc false

  import Timex, only: [shift: 2, beginning_of_day: 1]

  def shift_by(0, _, time), do: {:no_change, time}
  def shift_by(amount, type, time), do: {:updated, shift(time, "#{type}": amount)}

  def shift_by_bod(0, _, time), do: {:no_change, time}
  def shift_by_bod(amount, type, time), do: {:updated, shift(time, "#{type}": amount) |> beginning_of_day()}
end
