defmodule Cocktail.Rules do
  alias Cocktail.Rules.{Daily, Hourly, Minutely, Secondly}

  def daily(options), do: Daily.new(options)
  def hourly(options), do: Hourly.new(options)
  def minutely(options), do: Minutely.new(options)
  def secondly(options), do: Secondly.new(options)

  def next_time(%Daily{} = rule, start_time, time), do: Daily.next_time(rule, start_time, time)
  def next_time(%Hourly{} = rule, start_time, time), do: Hourly.next_time(rule, start_time, time)
  def next_time(%Minutely{} = rule, start_time, time), do: Minutely.next_time(rule, start_time, time)
  def next_time(%Secondly{} = rule, start_time, time), do: Secondly.next_time(rule, start_time, time)
end
