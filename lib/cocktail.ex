defmodule Cocktail do
  alias Cocktail.Schedule

  def schedule(start_time) do
    Schedule.new(start_time)
  end
end
