defmodule Cocktail.Span do
  defstruct [:from, :until]

  def new(from, until), do: %__MODULE__{from: from, until: until}

  def compare(%__MODULE__{from: t, until: until1}, %__MODULE__{from: t, until: until2}), do: until1 <= until2
  def compare(%__MODULE__{from: from1}, %__MODULE__{from: from2}), do: from1 <= from2
end
