defmodule Cocktail.Rules.Secondly do
  import Cocktail.Rules.Interval

  defstruct [ interval: 1 ]

  def new(options) do
    interval = Keyword.get(options, :interval, 1)
    %__MODULE__{ interval: interval }
  end

  def next_time(%__MODULE__{ interval: interval }, start_time, time) do
    apply_interval(time, start_time, interval, :seconds)
  end
end
