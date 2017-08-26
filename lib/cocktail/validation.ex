defmodule Cocktail.Validation do
  def next_time(%mod{} = validation, time, start_time), do: mod.next_time(validation, time, start_time)
end
