defmodule Cocktail.Util do
  @moduledoc false

  def next_gte([], _), do: nil
  def next_gte([x | rest], search), do: if(x >= search, do: x, else: next_gte(rest, search))

  def beginning_of_day(time) do
    time
    |> Timex.beginning_of_day()
    |> no_ms()
  end

  def beginning_of_month(time) do
    time
    |> Timex.beginning_of_month()
    |> no_ms()
  end

  def shift_time(datetime, opts) do
    datetime
    |> Timex.shift(opts)
    |> no_ms()
  end

  def no_ms(time) do
    Map.put(time, :microsecond, {0, 0})
  end
end
