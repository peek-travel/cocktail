defmodule Cocktail.Span do
  @moduledoc ~S"""
  TODO: write module doc
  """

  defstruct [:from, :until]

  @doc ~S"""
  TODO: write doc
  """
  def new(from, until), do: %__MODULE__{from: from, until: until}

  @doc ~S"""
  TODO: write doc
  """
  def compare(%__MODULE__{from: t, until: until1}, %__MODULE__{from: t, until: until2}), do: Timex.compare(until1, until2)
  def compare(%__MODULE__{from: from1}, %__MODULE__{from: from2}), do: Timex.compare(from1, from2)

  @doc ~S"""
  TODO: write doc
  """
  def overlap_mode(%__MODULE__{from: from, until: until}, %__MODULE__{from: from, until: until}), do: :is_equal_to
  def overlap_mode(%__MODULE__{from: from1, until: until1}, %__MODULE__{from: from2, until: until2}) do
    cond do
      Timex.compare(from1, from2) <= 0 && Timex.compare(until1, until2) >= 0 ->
        :contains
      Timex.compare(from1, from2) >= 0 && Timex.compare(until1, until2) <= 0 ->
        :is_inside
      Timex.compare(until1, from2) <= 0 ->
        :is_before
      Timex.compare(from1, until2) >= 0 ->
        :is_after
      Timex.compare(from1, from2) < 0 && Timex.compare(until1, until2) < 0 ->
        :overlaps_the_start_of
      Timex.compare(from1, from2) > 0 && Timex.compare(until1, until2) > 0 ->
        :overlaps_the_end_of
    end
  end
end
