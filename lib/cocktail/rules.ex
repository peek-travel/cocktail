defmodule Cocktail.Rules do
  alias Cocktail.Rules.Daily

  def daily(options), do: Daily.new(options)

  def next_time(%Daily{} = rule, start_time, time), do: Daily.next_time(rule, start_time, time)
end
