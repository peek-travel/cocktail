defmodule Cocktail.Rule do
  @moduledoc """
  Represent a recurrence rule (RRULE).
  """

  alias Cocktail.{Builder, Rule, Validation}

  @type t :: %__MODULE__{
          count: pos_integer | nil,
          until: Cocktail.time() | nil,
          validations: Validation.validations_map()
        }

  @enforce_keys [:validations]
  defstruct count: nil,
            until: nil,
            validations: %{}

  @spec new(Cocktail.rule_options()) :: t
  def new(options) do
    {count, options} = Keyword.pop(options, :count)
    {until, options} = Keyword.pop(options, :until)
    validations = Validation.build_validations(options)

    %Rule{count: count, until: until, validations: validations}
  end

  @spec set_until(t, Cocktail.time()) :: t
  def set_until(%__MODULE__{} = rule, end_time), do: %{rule | until: end_time}

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(rule, _) do
      concat(["#Cocktail.Rule<", Builder.String.build_rule(rule), ">"])
    end
  end
end
