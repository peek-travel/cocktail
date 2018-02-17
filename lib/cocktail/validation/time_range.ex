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
      case Time.compare(time, time_range.end_time) do
        :gt ->
          nil

        _ ->
          {time, time_add(time, time_range.interval_seconds)}
      end
    end)
    |> Enum.to_list()
  end

  @spec next_time(t(), Cocktail.time(), Cocktail.time()) :: Cocktail.Validation.Shift.result()
  def next_time(%__MODULE__{time_of_day: time_of_day}, time, start_time),
    do: TimeOfDay.next_time(time_of_day, time, start_time)

  if Version.compare(System.version(), "1.6.0") == :lt do
    # Yanked from Elixir 1.6.1 source code.  Remove once we drop support for Elixir < 1.6.
    @spec time_add(Calendar.time(), integer, System.time_unit()) :: t
    def time_add(%{calendar: calendar} = time, number, unit \\ :second) when is_integer(number) do
      number = System.convert_time_unit(number, unit, :microsecond)
      iso_days = {0, to_day_fraction(time)}
      total = Calendar.ISO.iso_days_to_unit(iso_days, :microsecond) + number
      iso_ppd = 86_400_000_000
      parts = Integer.mod(total, iso_ppd)

      {hour, minute, second, microsecond} = calendar.time_from_day_fraction({parts, iso_ppd})

      %Time{
        hour: hour,
        minute: minute,
        second: second,
        microsecond: microsecond,
        calendar: calendar
      }
    end

    defp to_day_fraction(%{
           hour: hour,
           minute: minute,
           second: second,
           microsecond: {_, _} = microsecond,
           calendar: calendar
         }) do
      calendar.time_to_day_fraction(hour, minute, second, microsecond)
    end
  else
    def time_add(time, amount, unit \\ :second), do: Time.add(time, amount, unit)
  end
end
