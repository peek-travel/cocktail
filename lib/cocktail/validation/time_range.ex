defmodule Cocktail.Validation.TimeRange do
  @moduledoc false

  alias Cocktail.Validation.TimeOfDay

  @type t :: %__MODULE__{
          start_time: Time.t(),
          end_time: Time.t(),
          interval_seconds: Cocktail.second_number(),
          time_of_day: TimeOfDay.t()
        }

  @enforce_keys [:start_time, :end_time, :interval_seconds]
  defstruct start_time: nil,
            end_time: nil,
            interval_seconds: nil,
            time_of_day: nil

  @spec new(Cocktail.time_range()) :: t()
  def new(attrs) do
    time_range = struct!(__MODULE__, attrs)
    times = generate_times(time_range)

    %{time_range | time_of_day: TimeOfDay.new(times)}
  end

  @spec generate_times(t()) :: [Time.t()]
  defp generate_times(%__MODULE__{} = time_range) do
    time_range.start_time
    |> Stream.unfold(fn time ->
      current_gt_end = Time.compare(time, time_range.end_time)
      next_time = Time.add(time, time_range.interval_seconds)
      current_gt_next = Time.compare(time, next_time)

      case {current_gt_end, current_gt_next} do
        {:gt, _} ->
          nil

        {_, :gt} ->
          nil

        _ ->
          {time, next_time}
      end
    end)
    |> Enum.to_list()
  end

  @spec next_time(t(), Cocktail.time(), Cocktail.time()) :: Cocktail.Validation.Shift.result()
  def next_time(%__MODULE__{time_of_day: time_of_day}, time, start_time),
    do: TimeOfDay.next_time(time_of_day, time, start_time)
end
