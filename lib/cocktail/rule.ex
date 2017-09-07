defmodule Cocktail.Rule do
  @moduledoc false

  alias Cocktail.{Rule, Validation}
  alias Cocktail.Builder.String, as: StringBuilder

  @type t :: %__MODULE__{
              count:       pos_integer | nil,
              until:       Cocktail.time | nil,
              validations: Validation.validations_map}

  @enforce_keys [:validations]
  defstruct count:       nil,
            until:       nil,
            validations: %{}

  @spec new(Cocktail.rule_options) :: t
  def new(options) do
    {count, options} = Keyword.pop(options, :count)
    {until, options} = Keyword.pop(options, :until)
    validations = Validation.build_validations(options)

    %Rule{count: count, until: until, validations: validations}
  end

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(rule, _) do
      concat ["#Cocktail.Rule<", StringBuilder.build_rule(rule), ">"]
    end
  end
end
