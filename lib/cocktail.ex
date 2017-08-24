defmodule Cocktail do
  alias Cocktail.Schedule

  def schedule(start_time, options \\ []), do: Schedule.new(start_time, options)
end
