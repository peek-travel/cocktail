defmodule Cocktail.Rule do
  alias Cocktail.Rule
  alias Cocktail.Rule.{Weekly, Daily, Hourly, Minutely, Secondly}

  defstruct [:count, :until, :validations]

  # TODO: use this somewhere
  # @validation_order [
  #   :year, :month, :day, :wday, :hour, :min, :sec, :count, :until,
  #   :base_sec, :base_min, :base_day, :base_hour, :base_month, :base_wday,
  #   :day_of_year, :second_of_minute, :minute_of_hour, :day_of_month,
  #   :hour_of_day, :month_of_year, :day_of_week,
  #   :interval
  # ]

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
