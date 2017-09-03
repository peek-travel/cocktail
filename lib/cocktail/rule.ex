defmodule Cocktail.Rule do
  @moduledoc ~S"""
  TODO: write module doc
  """

  alias Cocktail.{Rule, Validation}
  alias Cocktail.Builder.String, as: StringBuilder

  defstruct [:count, :until, :validations]

  @doc ~S"""
  TODO: write doc
  """
  def new(options) do
    {count, options} = Keyword.pop(options, :count)
    {until, options} = Keyword.pop(options, :until)
    validations = Validation.build_validations(options)

    %Rule{ count: count, until: until, validations: validations }
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(rule, _) do
      concat ["#Cocktail.Rule<", StringBuilder.build_rule(rule), ">"]
    end
  end
end
