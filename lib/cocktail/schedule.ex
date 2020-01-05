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
  a stream of occurrences, which are either `t:Cocktail.time/0`s or
  `t:Cocktail.Span.t/0`s if a `duration` option was given to the schedule.

  Various options can be given to modify the way the repeat rule and schedule
  behave. See `add_recurrence_rule/3` for details on them.
  """

  alias Cocktail.{Builder, Parser, Rule, ScheduleState}

  @typedoc """
  Struct used to represent a schedule of recurring events.

  This type should be considered opaque, so its fields shouldn't be modified
  directly. Instead, use the functions provided in this module to create and
  manipulate schedules.

  ## Fields:

    * `:start_time` - The schedule's start time
    * `:duration` - The duration of each occurrence (in seconds)
  """
  @type t :: %__MODULE__{
          recurrence_rules: [Rule.t()],
          recurrence_times: [Cocktail.time()],
          exception_times: [Cocktail.time()],
          start_time: Cocktail.time(),
          duration: pos_integer | nil
        }

  @enforce_keys [:start_time]
  defstruct recurrence_rules: [],
            recurrence_times: [],
            exception_times: [],
            start_time: nil,
            duration: nil

  @doc """
  Creates a new schedule using the given start time and options.

  This schedule will be empty and needs recurrence rules added to it before it is useful.
  Use `add_recurrence_rule/3` to add rules to a schedule.

  ## Options

    * `:duration` - The duration of each event in the schedule (in seconds).

  ## Examples

      iex> new(~N[2017-01-01 06:00:00], duration: 3_600)
      #Cocktail.Schedule<>
  """
  @spec new(Cocktail.time(), Cocktail.schedule_options()) :: t
  def new(start_time, options \\ []) do
    %__MODULE__{
      start_time: no_ms(start_time),
      duration: options[:duration]
    }
  end

  @doc false
  @spec set_start_time(t, Cocktail.time()) :: t
  def set_start_time(schedule, start_time), do: %{schedule | start_time: no_ms(start_time)}

  @doc false
  @spec set_duration(t, pos_integer) :: t
  def set_duration(schedule, duration), do: %{schedule | duration: duration}

  @doc false
  @spec set_end_time(t, Cocktail.time()) :: t
  def set_end_time(%__MODULE__{start_time: start_time} = schedule, end_time) do
    duration = Timex.diff(end_time, start_time, :seconds)
    %{schedule | duration: duration}
  end

  @doc false
  @spec add_recurrence_rule(t, Rule.t()) :: t
  def add_recurrence_rule(%__MODULE__{} = schedule, %Rule{} = rule) do
    %{schedule | recurrence_rules: [rule | schedule.recurrence_rules]}
  end

  @doc """
  Adds a recurrence rule of the given frequency to a schedule.

  The frequency can be one of `:monthly`, `:weekly`, `:daily`, `:hourly`, `:minutely` or `:secondly`

  ## Options

    * `:interval` - How often to repeat, given the frequency. For example a `:daily` rule with interval `2` would be "every other day".
    * `:count` - The number of times this rule can produce an occurrence. *(not yet support)*
    * `:until` - The end date/time after which the rule will no longer produce occurrences.
    * `:days` - Restrict this rule to specific days. (e.g. `[:monday, :wednesday, :friday]`)
    * `:hours` - Restrict this rule to certain hours of the day. (e.g. `[10, 12, 14]`)
    * `:minutes` - Restrict this rule to certain minutes of the hour. (e.g. `[0, 15, 30, 45]`)
    * `:seconds` - Restrict this rule to certain seconds of the minute. (e.g. `[0, 30]`)

  > NOTE: more options are planned to be supported in the future. (e.g. `:days_of_month`)

  ## Examples

      iex> start_time = ~N[2017-01-01 06:00:00]
      ...> start_time |> new() |> add_recurrence_rule(:daily, interval: 2, hours: [10, 14])
      #Cocktail.Schedule<Every 2 days on the 10th and 14th hours of the day>
  """
  @spec add_recurrence_rule(t, Cocktail.frequency(), Cocktail.rule_options()) :: t
  def add_recurrence_rule(%__MODULE__{} = schedule, frequency, options \\ []) do
    rule =
      options
      |> Keyword.put(:frequency, frequency)
      |> Rule.new()

    add_recurrence_rule(schedule, rule)
  end

  @doc """
  Adds a one-off recurrence time to the schedule.

  This recurrence time can be any time after (or including) the schedule's start
  time. When generating occurrences from this schedule, the given time will be
  included in the set of occurrences alongside any recurrence rules.
  """
  @spec add_recurrence_time(t, Cocktail.time()) :: t
  def add_recurrence_time(%__MODULE__{} = schedule, time),
    do: %{schedule | recurrence_times: [no_ms(time) | schedule.recurrence_times]}

  @doc """
  Adds an exception time to the schedule.

  This exception time will cancel out any occurrence generated from the
  schedule's recurrence rules or recurrence times.
  """
  @spec add_exception_time(t, Cocktail.time()) :: t
  def add_exception_time(%__MODULE__{} = schedule, time),
    do: %{schedule | exception_times: [no_ms(time) | schedule.exception_times]}

  @doc """
  Creates a stream of occurrences from the given schedule.

  An optional `start_time` can be supplied to not start at the schedule's start time.

  The occurrences that are produced by the stream can be one of several types:
    * If the schedule's start time is a `t:DateTime.t/0`, then it will produce
      `t:DateTime.t/0`s
    * If the schedule's start time is a `t:NaiveDateTime.t/0`, the it will
      produce `t:NaiveDateTime.t/0`s
    * If a duration is supplied when creating the schedule, the stream will
      produce `t:Cocktail.Span.t/0`s with `:from` and `:until` fields matching
      the type of the schedule's start time

  ## Examples

      # using a NaiveDateTime
      iex> start_time = ~N[2017-01-01 06:00:00]
      ...> schedule = start_time |> new() |> add_recurrence_rule(:daily, interval: 2, hours: [10, 14])
      ...> schedule |> occurrences() |> Enum.take(3)
      [~N[2017-01-01 10:00:00],
       ~N[2017-01-01 14:00:00],
       ~N[2017-01-03 10:00:00]]

      # using an alternate start time
      iex> start_time = ~N[2017-01-01 06:00:00]
      ...> schedule = start_time |> new() |> add_recurrence_rule(:daily, interval: 2, hours: [10, 14])
      ...> schedule |> occurrences(~N[2017-10-01 06:00:00]) |> Enum.take(3)
      [~N[2017-10-02 10:00:00],
       ~N[2017-10-02 14:00:00],
       ~N[2017-10-04 10:00:00]]

      # using a DateTime with a time zone
      iex> start_time = Timex.to_datetime(~N[2017-01-02 10:00:00], "America/Los_Angeles")
      ...> schedule = start_time |> new() |> add_recurrence_rule(:daily)
      ...> schedule |> occurrences() |> Enum.take(3) |> Enum.map(&Timex.format!(&1, "{ISO:Extended}"))
      ["2017-01-02T10:00:00-08:00",
       "2017-01-03T10:00:00-08:00",
       "2017-01-04T10:00:00-08:00"]

      # using a NaiveDateTime with a duration
      iex> start_time = ~N[2017-02-01 12:00:00]
      ...> schedule = start_time |> new(duration: 3_600) |> add_recurrence_rule(:weekly)
      ...> schedule |> occurrences() |> Enum.take(3)
      [%Cocktail.Span{from: ~N[2017-02-01 12:00:00], until: ~N[2017-02-01 13:00:00]},
       %Cocktail.Span{from: ~N[2017-02-08 12:00:00], until: ~N[2017-02-08 13:00:00]},
       %Cocktail.Span{from: ~N[2017-02-15 12:00:00], until: ~N[2017-02-15 13:00:00]}]
  """
  @spec occurrences(t, Cocktail.time() | nil) :: Enumerable.t()
  def occurrences(%__MODULE__{} = schedule, start_time \\ nil) do
    schedule
    |> ScheduleState.new(no_ms(start_time))
    |> Stream.unfold(&ScheduleState.next_time/1)
  end

  @doc """
  Add an end time to all recurrence rules in the schedule.

  This has the same effect as if you'd passed the `:until` option when adding
  all recurrence rules to the schedule.
  """
  @spec end_all_recurrence_rules(t, Cocktail.time()) :: t
  def end_all_recurrence_rules(%__MODULE__{recurrence_rules: rules} = schedule, end_time),
    do: %{schedule | recurrence_rules: Enum.map(rules, &Rule.set_until(&1, end_time))}

  @doc """
  Parses a string in iCalendar format into a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Parser.ICalendar.parse/1` for details.
  """
  @spec from_i_calendar(String.t()) :: {:ok, t} | {:error, term}
  def from_i_calendar(i_calendar_string), do: Parser.ICalendar.parse(i_calendar_string)

  @doc """
  Builds an iCalendar format string representation of a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Builder.ICalendar.build/1` for details.
  """
  @spec to_i_calendar(t) :: String.t()
  def to_i_calendar(%__MODULE__{} = schedule), do: Builder.ICalendar.build(schedule)

  @doc """
  Builds a human readable string representation of a `t:Cocktail.Schedule.t/0`.

  see `Cocktail.Builder.String.build/1` for details.
  """
  @spec to_string(t) :: String.t()
  def to_string(%__MODULE__{} = schedule), do: Builder.String.build(schedule)

  @spec no_ms(Cocktail.time() | nil) :: Cocktail.time() | nil
  defp no_ms(nil), do: nil
  defp no_ms(time), do: %{time | microsecond: {0, 0}}

  defimpl Inspect, for: __MODULE__ do
    import Inspect.Algebra

    def inspect(schedule, _) do
      concat(["#Cocktail.Schedule<", Builder.String.build(schedule), ">"])
    end
  end
end
