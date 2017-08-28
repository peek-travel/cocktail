defmodule Cocktail.Rule do
  alias Cocktail.Validation
  alias Cocktail.Rule.{Weekly, Daily, Hourly, Minutely, Secondly}

  defstruct [ count: nil, until: nil, validations: [] ]

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

    %__MODULE__{ count: count, until: until, validations: validations }
  end

  def next_time(%__MODULE__{ validations: validations }, time, start_time) do
    Enum.reduce(validations, time, &do_next_time(&1, &2, start_time))
  end

  defp do_next_time({ _, validations }, time, start_time) do
    validations
    |> Enum.map(&Validation.next_time(&1, time, start_time))
    |> Enum.min_by(&Timex.to_unix/1)
  end

  defp build_validations(:weekly, options), do: Weekly.build_validations(options)
  defp build_validations(:daily, options), do: Daily.build_validations(options)
  defp build_validations(:hourly, options), do: Hourly.build_validations(options)
  defp build_validations(:minutely, options), do: Minutely.build_validations(options)
  defp build_validations(:secondly, options), do: Secondly.build_validations(options)
end
