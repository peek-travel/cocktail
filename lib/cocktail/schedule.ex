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
  @spec new(DateTime.t, Cocktail.schedule_options) :: t
  def new(start_time, options \\ []) do
    %__MODULE__{recurrence_rules: [], start_time: start_time, duration: options[:duration]}
  end

  @doc false
  @spec add_recurrence_rule(t, Rule.t) :: t
  def add_recurrence_rule(%__MODULE__{} = schedule, %Rule{} = rule) do
    %{schedule | recurrence_rules: [rule | schedule.recurrence_rules]}
  end

  @doc """
  TODO: write doc
  """
  @spec add_recurrence_rule(t, Cocktail.frequency, Cocktail.rule_options) :: t
  def add_recurrence_rule(%__MODULE__{} = schedule, frequency, options \\ []) do
    rule =
      options
      |> Keyword.put(:frequency, frequency)
      |> Rule.new

    add_recurrence_rule(schedule, rule)
  end

  @doc """
  TODO: write doc
  """
  @spec occurrences(t, DateTime.t | nil) :: Enumerable.t
  def occurrences(%__MODULE__{} = schedule, start_time \\ nil) do
    schedule
    |> ScheduleState.new(start_time)
    |> Stream.unfold(&ScheduleState.next_time/1)
  end

  @doc """
  Parses a string in iCalendar format into a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Parser.ICalendar.parse/1` for details.
  """
  @spec from_i_calendar(String.t) :: {:ok, t} | {:error, term}
  def from_i_calendar(i_calendar_string), do: ICalendar.parse(i_calendar_string)

  @doc """
  Parses a string of JSON into a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Parser.JSON.parse/1` for details.
  """
  @spec from_json(String.t) :: {:ok, t} | {:error, term}
  def from_json(json_string), do: JSON.parse(json_string)

  @doc """
  Parses JSON-like map into a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Parser.JSON.parse_map/1` for details.
  """
  # TODO: write spec
  @spec from_map(map) :: {:ok, t} | {:error, term}
  def from_map(map), do: JSON.parse_map(map)

  @doc """
  Builds an iCalendar format string represenation of a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Builder.ICalendar.build/1` for details.
  """
  @spec to_i_calendar(t) :: String.t
  def to_i_calendar(%__MODULE__{} = schedule), do: ICalendarBuilder.build(schedule)

  @doc """
  Builds a human readable string represenation of a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Builder.String.build/1` for details.
  """
  @spec to_string(t) :: String.t
  def to_string(%__MODULE__{} = schedule), do: StringBuilder.build(schedule)

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(schedule, _) do
      concat ["#Cocktail.Schedule<", StringBuilder.build(schedule), ">"]
    end
  end
end
