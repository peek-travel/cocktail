defmodule Cocktail.Rules.Minutely do
  import Cocktail.Rules.Lock
  import Cocktail.Rules.Interval

  defstruct [ interval: 1 ]

  def new(options) do
    interval = Keyword.get(options, :interval, 1)
    %__MODULE__{ interval: interval }
  end

  def next_time(%__MODULE__{ interval: interval }, start_time, time) do
    time
    |> lock_seconds(start_time)
    |> apply_interval(start_time, interval, :minutes)
  end
end
