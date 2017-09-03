defmodule Cocktail do
  @moduledoc ~S"""
  TODO: write module doc
  """

  alias Cocktail.Schedule

  @doc ~S"""
  TODO: write doc
  """
  def schedule(start_time, options \\ []), do: Schedule.new(start_time, options)
end
