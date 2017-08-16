defmodule Cocktail.Span do
  defstruct [:from, :until]

  def new(from, until), do: %__MODULE__{from: from, until: until}
end
