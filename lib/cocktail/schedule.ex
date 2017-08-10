defmodule Cocktail.Schedule do
  defstruct [ recurrence_rules: [] ]

  alias Cocktail.Rules

  def new do
    %__MODULE__{}
  end

  def add_recurrence_rule(%__MODULE__{ recurrence_rules: recurrence_rules } = schedule, :daily) do
    %{ schedule | recurrence_rules: recurrence_rules ++ [Rules.daily] }
  end
end
