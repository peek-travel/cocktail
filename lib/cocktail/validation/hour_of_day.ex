defmodule Cocktail.Validation.HourOfDay do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift
  import Cocktail.Util, only: [next_gte: 2]

  require Logger

  @type t :: %__MODULE__{hours: [Cocktail.hour_number]}

  @enforce_keys [:hours]
  defstruct hours: []

  @spec new([Cocktail.hour_number]) :: t
  def new(hours), do: %__MODULE__{hours: Enum.sort(hours)}

  @spec next_time(t, Cocktail.time, Cocktail.time) :: Cocktail.Validation.Shift.result
  def next_time(%__MODULE__{hours: hours}, time, _) do
    current_hour = time.hour
    hour = next_gte(hours, current_hour) || hd(hours)
    diff = hour - current_hour |> mod(24)

    result = shift_by(diff, :hours, time, :beginning_of_hour)
    Logger.debug(fn ->
      "    hour_of_day(#{Enum.join(hours, ", ")}): #{inspect result}"
    end)
    result
  end
end
