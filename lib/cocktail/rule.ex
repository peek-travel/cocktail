defmodule Cocktail.Rule do
  @moduledoc """
  TODO: write module doc
  """

  alias Cocktail.{Rule, Validation}
  alias Cocktail.Builder.String, as: StringBuilder

  @typedoc """
  TODO: write typedoc
  """
  @opaque t :: %__MODULE__{
              count:       pos_integer | nil,
              until:       DateTime.t | nil,
              validations: %{atom => [Validation.t]}}

  @enforce_keys [:validations]
  defstruct count:       nil,
            until:       nil,
            validations: %{}

  @doc """
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
