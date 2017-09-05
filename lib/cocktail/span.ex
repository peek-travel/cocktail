defmodule Cocktail.Span do
  @moduledoc """
  TODO: write module doc
  """

  @type t :: %__MODULE__{
              from:  DateTime.t,
              until: DateTime.t}

  @type overlap_mode :: :contains              |
                        :is_inside             |
                        :is_before             |
                        :is_after              |
                        :overlaps_the_start_of |
                        :overlaps_the_end_of

  @enforce_keys [:from, :until]
  defstruct from:  nil,
            until: nil

  @doc """
  TODO: write doc
  """
  @spec new(DateTime.t, DateTime.t) :: t
  def new(from, until), do: %__MODULE__{from: from, until: until}

  @doc """
  TODO: write doc
  """
  @spec compare(t, t) :: Timex.Comparable.compare_result
  def compare(%__MODULE__{from: t, until: until1}, %__MODULE__{from: t, until: until2}), do: Timex.compare(until1, until2)
  def compare(%__MODULE__{from: from1}, %__MODULE__{from: from2}), do: Timex.compare(from1, from2)

  @doc """
  TODO: write doc
  """
  @spec overlap_mode(t, t) :: overlap_mode
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
