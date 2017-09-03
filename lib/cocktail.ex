defmodule Cocktail do
  @moduledoc """
  TODO: write module doc
  """

  alias Cocktail.Schedule

  @doc """
  see `Cocktail.Schedule.new/1`
  """
  def schedule(start_time, options \\ []), do: Schedule.new(start_time, options)
end
