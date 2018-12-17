defmodule Cocktail.Validation.TimeOfDay do
  @moduledoc false

  import Cocktail.Validation.Shift
  import Cocktail.Util, only: [next_gte: 2]

  @type time :: {Cocktail.hour_number(), Cocktail.minute_number(), Cocktail.second_number()}

  @type t :: %__MODULE__{times: [time]}

  @enforce_keys [:times]
  defstruct times: []

  @spec new([Time.t()]) :: t
  def new(times), do: %__MODULE__{times: times |> Enum.map(&Time.to_erl/1) |> Enum.sort()}

  @spec next_time(t, Cocktail.time(), Cocktail.time()) :: Cocktail.Validation.Shift.result()
  def next_time(%__MODULE__{times: times}, time, _) do
    current_time = to_time(time)
    target_time = Time.from_erl!(next_gte(times, Time.to_erl(current_time)) || List.first(times))

    diff = Time.diff(target_time, current_time)
    diff = if diff < 0, do: diff + 86_400, else: diff

    shift_by(diff, :seconds, time)
  end

  @spec to_time(Cocktail.time()) :: Time.t()
  defp to_time(%DateTime{} = time), do: DateTime.to_time(time)
  defp to_time(%NaiveDateTime{} = time), do: NaiveDateTime.to_time(time)
end
