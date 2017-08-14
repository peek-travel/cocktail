defmodule Cocktail.Rules.Secondly do
  import Cocktail.Rules.Interval

  defstruct [ interval: 1, count: nil, until: nil ]

  def new(options) do
    interval = Keyword.get(options, :interval, 1)
    count = Keyword.get(options, :count)
    until = Keyword.get(options, :until)
    %__MODULE__{ interval: interval, count: count, until: until }
  end

  def next_time(%__MODULE__{ interval: interval }, start_time, time) do
    apply_interval(time, start_time, interval, :seconds)
  end
end
