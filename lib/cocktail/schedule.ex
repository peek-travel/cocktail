defmodule Cocktail.Schedule do
  @moduledoc """
  TODO: write module doc
  """

  alias Cocktail.{Rule, ScheduleState}
  alias Cocktail.Parser.{ICalendar, JSON}
  alias Cocktail.Builder.String, as: StringBuilder
  alias Cocktail.Builder.ICalendar, as: ICalendarBuilder

  @typedoc """
  TODO: write typedoc
  """
  @opaque t :: %__MODULE__{
                recurrence_rules: [Rule.t],
                start_time:       DateTime.t,
                duration:         pos_integer | nil}

  @enforce_keys [:recurrence_rules, :start_time]
  defstruct recurrence_rules: [],
            start_time:       nil,
            duration:         nil

  @doc """
  TODO: write doc
  """
  def new(start_time, options \\ []) do
    %__MODULE__{ recurrence_rules: [], start_time: start_time, duration: options[:duration] }
  end

  @doc """
  TODO: write doc
  """
  def add_recurrence_rule(%__MODULE__{} = schedule, %Rule{} = rule) do
    %{ schedule | recurrence_rules: [rule | schedule.recurrence_rules] }
  end

  @doc """
  TODO: write doc
  """
  def occurrences(%__MODULE__{} = schedule, start_time \\ nil) do
    schedule
    |> ScheduleState.new(start_time)
    |> Stream.unfold(&ScheduleState.next_time/1)
  end

  @doc """
  see `Cocktail.Parser.ICalendar.parse/1`
  """
  def from_i_calendar(i_calendar_string), do: ICalendar.parse(i_calendar_string)

  @doc """
  see `Cocktail.Parser.JSON.parse/1`
  """
  def from_json(json_string), do: JSON.parse(json_string)

  @doc """
  see `Cocktail.Parser.JSON.parse_map/1`
  """
  def from_map(map), do: JSON.parse(map)

  @doc """
  see `Cocktail.Builder.ICalendar.build/1`
  """
  def to_i_calendar(%__MODULE__{} = schedule), do: ICalendarBuilder.build(schedule)

  @doc """
  see `Cocktail.Builder.String.build/1`
  """
  def to_string(%__MODULE__{} = schedule), do: StringBuilder.build(schedule)

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(schedule, _) do
      concat ["#Cocktail.Schedule<", StringBuilder.build(schedule), ">"]
    end
  end
end
