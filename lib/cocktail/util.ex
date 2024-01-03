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
    |> shift_dst(datetime)
    |> no_ms()
  end

  def no_ms(time) do
    Map.put(time, :microsecond, {0, 0})
  end

  # In case of datetime we may expect the same timezone hour
  # For example after daylight saving 10h MUST still 10h the next day.
  # This behaviour could only happen on datetime with timezone (that include `std_offset`)
  defp shift_dst(time, datetime) do
    if offset = Map.get(datetime, :std_offset) do
      Timex.shift(time, seconds: offset - time.std_offset)
    else
      time
    end
  end
end
