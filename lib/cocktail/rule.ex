defmodule Cocktail.Rule do
  alias Cocktail.Rule
  alias Cocktail.Rule.{Weekly, Daily, Hourly, Minutely, Secondly}

  defstruct [:count, :until, :validations]

  def new(frequency, options) do
    {count, options} = Keyword.pop(options, :count)
    {until, options} = Keyword.pop(options, :until)
    validations = build_validations(frequency, options)

    %Rule{ count: count, until: until, validations: validations }
  end

  defp build_validations(:weekly, options), do: Weekly.build_validations(options)
  defp build_validations(:daily, options), do: Daily.build_validations(options)
  defp build_validations(:hourly, options), do: Hourly.build_validations(options)
  defp build_validations(:minutely, options), do: Minutely.build_validations(options)
  defp build_validations(:secondly, options), do: Secondly.build_validations(options)
end
