defmodule Cocktail.Schedule do
  @moduledoc """
  Struct used to represent a schedule of recurring events.

  Use the `new/2` function to create a new schedule, and the
  `add_recurrence_rule/2` function to add rules to describe how to repeat.

  Currently, Cocktail supports the following types of repeat rules:

    * Weekly - Every week, relative to the schedule's start time
    * Daily - Every day at the schedule's start time
    * Hourly - Every hour, starting at the schedule's start time
    * Minutely - Every minute, starting at the schedule's start time
    * Secondly - Every second, starting at the schedule's start time

  Once a schedule has been created, you can use `occurrences/2` to generate
  a stream of occurrences, which are either `t:DateTime.t/0`s or
  `t:Cocktail.Span.t/0`s if a `duration` option was given to the schedule.

  Various options can be given to modify the way the repeat rule and schedule
  behave. See `add_recurrence_rule/3` for details on them.
  """

  alias Cocktail.{Rule, ScheduleState}
  alias Cocktail.Parser.{ICalendar, JSON}
  alias Cocktail.Builder.String, as: StringBuilder
  alias Cocktail.Builder.ICalendar, as: ICalendarBuilder

  @typedoc """
  Struct used to represent a schedule of recurring events.

  This type is opaque, so its fields shouldn't be modified directly. Instead,
  use the functions provided in this module to create and manipulate schedules.

  ## Fields:

    * `:start_time` - The schedule's start time
    * `:duration` - The duration of each occurrence (in seconds)
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
  Creates a new schedule using the given start time and options.

  This schdule will be empty and needs recurrence rules added to it before it is useful.
  Use `add_recurrence_rule/3` to add rules to a schedule.

  ## Options

    * `:duration` - The duration of each event in the schedule (in seconds).

  ## Examples

      iex> start_time = Timex.to_datetime(~N[2017-01-01 06:00:00], "America/Los_Angeles")
      ...> new(start_time, duration: 3_600)
      #Cocktail.Schedule<>
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
  Adds a recurrence rule of the given frequency to a schedule.

  The frequency can be one of `:weekly`, `:daily`, `:hourly`, `:minutely` or `:secondly`.

  > NOTE: more frequencies are planned to be supported in the future. (e.g. `:monthly`)

  ## Options

    * `:interval` - How often to repeat, given the frequency. For example a `:daily` rule with interval `2` would be "every other day".
    * `:count` - The number of times this rule can produce an occurrence.
    * `:until` - The end date/time after which the rule will no longer produce occurrences.
    * `:days` - Restrict this rule to specific days. (e.g. `[:monday, :wednesday, :friday]`)
    * `:hours` - Restrict this rule to certain hours of the day. (e.g. `[10, 12, 14]`)

  > NOTE: more options are planned to be supported in the future. (e.g. `:days_of_month`)

  ## Examples

      iex> start_time = Timex.to_datetime(~N[2017-01-01 06:00:00], "America/Los_Angeles")
      ...> start_time |> new() |> add_recurrence_rule(:daily, interval: 2, hours: [10, 14])
      #Cocktail.Schedule<Every 2 days on the 10th and 14th hours of the day>
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
  Creates a stream of occurrences from the given schedule.

  An optional `start_time` can be supplied to not start at the schedule's start time.

  ## Examples

      iex> start_time = Timex.to_datetime(~N[2017-01-01 06:00:00], "America/Los_Angeles")
      ...> schedule = start_time |> new() |> add_recurrence_rule(:daily, interval: 2, hours: [10, 14])
      ...> schedule |> occurrences() |> Stream.map(&inspect/1) |> Enum.take(3)
      ["#DateTime<2017-01-01 10:00:00-08:00 PST America/Los_Angeles>",
       "#DateTime<2017-01-01 14:00:00-08:00 PST America/Los_Angeles>",
       "#DateTime<2017-01-03 10:00:00-08:00 PST America/Los_Angeles>"]
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
