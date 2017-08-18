defmodule Cocktail.Span do
  defstruct [:from, :until]

  def new(from, until), do: %__MODULE__{from: from, until: until}

  def compare(%__MODULE__{from: t, until: until1}, %__MODULE__{from: t, until: until2}), do: until1 <= until2
  def compare(%__MODULE__{from: from1}, %__MODULE__{from: from2}), do: from1 <= from2

  def overlap_mode(%__MODULE__{from: from, until: until}, %__MODULE__{from: from, until: until}), do: :is_equal_to
  def overlap_mode(%__MODULE__{from: from1, until: until1}, %__MODULE__{from: from2, until: until2}) when from1 <= from2 and until1 >= until2, do: :contains
  def overlap_mode(%__MODULE__{from: from1, until: until1}, %__MODULE__{from: from2, until: until2}) when from1 >= from2 and until1 <= until2, do: :is_inside
  def overlap_mode(%__MODULE__{until: until1}, %__MODULE__{from: from2}) when until1 <= from2, do: :is_before
  def overlap_mode(%__MODULE__{from: from1}, %__MODULE__{until: until2}) when from1 >= until2, do: :is_after
  def overlap_mode(%__MODULE__{from: from1, until: until1}, %__MODULE__{from: from2, until: until2}) when from1 < from2 and until1 < until2, do: :overlaps_the_start_of
  def overlap_mode(%__MODULE__{from: from1, until: until1}, %__MODULE__{from: from2, until: until2}) when from1 > from2 and until1 > until2, do: :overlaps_the_end_of
end
