defmodule Cocktail.Validation.MinuteOfHour do
  @moduledoc false

  import Integer, only: [mod: 2]
  import Cocktail.Validation.Shift
  import Cocktail.Util, only: [next_gte: 2]

  @type t :: %__MODULE__{minutes: [Cocktail.minute_number()]}

  @enforce_keys [:minutes]
  defstruct minutes: []

  @spec new([Cocktail.minute_number()]) :: t
  def new(minutes), do: %__MODULE__{minutes: minutes |> Enum.sort()}

  @spec next_time(t, Cocktail.time(), Cocktail.time()) :: Cocktail.Validation.Shift.result()
  def next_time(%__MODULE__{minutes: minutes}, time, _) do
    current_minute = time.minute
    minute = next_gte(minutes, current_minute) || hd(minutes)
    diff = (minute - current_minute) |> mod(60)

    shift_by(diff, :minutes, time, :beginning_of_minute)
  end
end
