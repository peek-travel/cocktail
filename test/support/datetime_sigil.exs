defmodule Cocktail.TestSupport.DateTimeSigil do
  def sigil_Y(string, []) do
    [date, time, zone] = String.split(string, " ")

    "#{date} #{time}"
    |> NaiveDateTime.from_iso8601!
    |> Timex.to_datetime(zone)
  end
end
