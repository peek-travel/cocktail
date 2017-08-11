defmodule Cocktail.Rules.Daily do
  defstruct [ interval: 1 ]

  def new do
    %__MODULE__{}
  end

  # TODO: interval
  def next_time(%__MODULE__{} = _rule, %DateTime{ second: s, minute: m, hour: h }, %DateTime{ second: s, minute: m, hour: h } = time), do: time
  def next_time(%__MODULE__{} = _rule, %DateTime{ second: ss, minute: sm, hour: sh }, %DateTime{ second: s } = time) do
    time = Timex.shift(time, seconds: mod(ss - s, 60))
    m = time.minute
    time = Timex.shift(time, minutes: mod(sm - m, 60))
    h = time.hour
    Timex.shift(time, hours: mod(sh - h, 24))
  end

  defp mod(x, y), do: rem(rem(x, y) + y, y)
end
