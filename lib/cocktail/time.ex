defmodule Cocktail.Time do
  @moduledoc """
  Struct used to represent a time.
  """
  @type interval :: :month | :day | :hour | :minute | System.time_unit()

  @doc """
  Shifts the given time by the given amount.

    ## Examples

      iex> shift(~N[2023-09-24 09:30:30], 1, :month)
      ~N[2023-10-24 09:30:30]
      iex> shift(~U[2023-09-24 09:30:30Z], 1, :month)
      ~U[2023-10-24 09:30:30Z]
      iex> shift(~N[2023-09-24 09:30:30], 1, :day)
      ~N[2023-09-25 09:30:30]
      iex> shift(~U[2023-09-24 09:30:30Z], 1, :hour)
      ~U[2023-09-24 10:30:30Z]
      iex> shift(~N[2023-09-24 09:30:30], -100, :month)
      ~N[2015-05-24 09:30:30]
      iex> shift(~N[2023-09-30 09:30:30], 1, :month)
      ~N[2023-10-30 09:30:30]
  """
  @spec shift(datetime :: Cocktail.time(), amount :: integer(), interval :: interval()) :: Cocktail.time()
  def shift(datetime, 0, :month), do: datetime

  def shift(datetime, amount, :month) do
    %{
      year: year,
      month: month,
      day: day,
      hour: hour,
      minute: minute,
      second: second,
      microsecond: microsecond
    } = datetime

    timezone = Map.get(datetime, :time_zone)

    new_datetime =
      case {month, amount} do
        {12, amount} when amount > 0 ->
          new_coerced_datetime(year + 1, 1, day, hour, minute, second, microsecond, timezone)

        {1, amount} when amount < 0 ->
          new_coerced_datetime(year - 1, 12, day, hour, minute, second, microsecond, timezone)

        {month, amount} when amount > 0 ->
          new_coerced_datetime(year, month + 1, day, hour, minute, second, microsecond, timezone)

        {month, amount} when amount < 0 ->
          new_coerced_datetime(year, month - 1, day, hour, minute, second, microsecond, timezone)
      end

    cond do
      amount == 0 -> datetime
      amount > 0 -> shift(new_datetime, amount - 1, :month)
      amount < 0 -> shift(new_datetime, amount + 1, :month)
    end
  end

  def shift(%NaiveDateTime{} = datetime, amount, interval) do
    NaiveDateTime.add(datetime, amount, interval)
  end

  def shift(%DateTime{} = datetime, amount, interval) do
    time = DateTime.add(datetime, amount, interval, get_time_zone_datebase())

    # In case of datetime we may expect the same timezone hour
    # For example after daylight saving 10h MUST still 10h the next day.
    # This behaviour could only happen on datetime with timezone (that include `std_offset`)
    if offset = Map.get(datetime, :std_offset) do
      DateTime.add(time, offset - time.std_offset, :second)
    else
      time
    end
  end

  defp new_coerced_datetime(year, month, day, hour, minute, second, microsecond, timezone) do
    days_in_month_b = :calendar.last_day_of_the_month(year, month)

    day =
      if day > days_in_month_b do
        days_in_month_b
      else
        day
      end

    {:ok, date} = Date.new(year, month, day)
    {:ok, time} = Time.new(hour, minute, second, microsecond)

    result =
      if is_nil(timezone) do
        NaiveDateTime.new(date, time)
      else
        DateTime.new(date, time, timezone, get_time_zone_datebase())
      end

    case result do
      {:ok, datetime} -> datetime
      {:ambiguous, _dt_before, dt_after} -> dt_after
      {:error, error} -> {:error, error}
    end
  end

  @doc """
  Returns the difference between two times in the given interval.

    ## Examples

    iex> diff(~N[2023-09-24 09:30:31], ~N[2023-09-24 09:30:30], :second)
    1
    iex> diff(~N[2023-09-24 09:32:30], ~N[2023-09-24 09:30:30], :minute)
    2
    iex> diff(~N[2023-09-24 12:30:30], ~N[2023-09-24 09:30:30], :hour)
    3
    iex> diff(~N[2023-09-28 09:30:30], ~N[2023-09-24 09:30:30], :day)
    4
    iex> diff(~N[2024-02-24 09:30:30], ~N[2023-09-24 09:30:30], :month)
    5
    iex> diff(~N[2024-12-24 09:30:30], ~N[2022-09-24 09:30:30], :month)
    27
    iex> diff(~N[2000-01-01 00:00:00], ~N[2001-01-01 00:00:00], :month)
    -12
    iex> diff(~T[12:00:00], ~T[10:00:00], :hour)
    2
  """
  @spec diff(
          a :: Cocktail.time() | Date.t() | Time.t(),
          b :: Cocktail.time() | Date.t() | Time.t(),
          interval :: interval()
        ) :: integer()
  def diff(a, b, interval) do
    case {a, b, interval} do
      {_, _, :month} ->
        difference_in_months(a, b)

      {%Date{}, %Date{}, :day} ->
        Date.diff(a, b)

      {%Time{}, %Time{}, _} ->
        Time.diff(a, b, interval)

      {%NaiveDateTime{}, %NaiveDateTime{}, _} ->
        NaiveDateTime.diff(a, b, interval)

      {%DateTime{}, %DateTime{}, _} ->
        DateTime.diff(a, b, interval)
    end
  end

  defp difference_in_months(date_time1, date_time2) do
    {{year1, month1, _day1}, {_hour1, _minute1, _second1}} = to_erl(date_time1)
    {{year2, month2, _day2}, {_hour2, _minute2, _second2}} = to_erl(date_time2)

    total_months1 = year1 * 12 + month1
    total_months2 = year2 * 12 + month2

    total_months1 - total_months2
  end

  @doc """
  Returns the beginning of the day for the given time.

    ## Examples

    iex> beginning_of_day(~N[2023-09-24 09:00:00])
    ~N[2023-09-24 00:00:00]
    iex> beginning_of_day(~U[2023-09-24 09:00:00Z])
    ~U[2023-09-24 00:00:00Z]
  """
  @spec beginning_of_day(Cocktail.time()) :: Cocktail.time()
  def beginning_of_day(%NaiveDateTime{} = datetime) do
    %{year: year, month: month, day: day, microsecond: {_, precision}} = datetime
    {:ok, datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0, {0, precision})
    datetime
  end

  def beginning_of_day(%DateTime{} = datetime) do
    {_, precision} = datetime.microsecond
    {:ok, time} = Time.new(0, 0, 0, {0, precision})
    date = DateTime.to_date(datetime)
    {:ok, datetime} = DateTime.new(date, time, datetime.time_zone, get_time_zone_datebase())
    datetime
  end

  @doc """
  Returns the beginning of the month for the given time.

    ## Examples

    iex> beginning_of_month(~N[2023-09-24 09:30:30])
    ~N[2023-09-01 00:00:00]
    iex> beginning_of_month(~N[2023-09-24 09:30:30.500])
    ~N[2023-09-01 00:00:00.000]
    iex> beginning_of_month(~N[2023-09-24 09:30:30.500000])
    ~N[2023-09-01 00:00:00.000000]
    iex> beginning_of_month(~U[2023-09-24 09:30:30Z])
    ~U[2023-09-01 00:00:00Z]
    iex> beginning_of_month(~U[2023-09-24 09:30:30.500Z])
    ~U[2023-09-01 00:00:00.000Z]
    iex> beginning_of_month(~U[2023-09-24 09:30:30.500000Z])
    ~U[2023-09-01 00:00:00.000000Z]
  """
  @spec beginning_of_month(Cocktail.time()) :: Cocktail.time()
  def beginning_of_month(%NaiveDateTime{} = datetime) do
    %{year: year, month: month, microsecond: {_, precision}} = datetime
    {:ok, datetime} = NaiveDateTime.new(year, month, 1, 0, 0, 0, {0, precision})
    datetime
  end

  def beginning_of_month(%DateTime{} = datetime) do
    %{year: year, month: month, time_zone: time_zone, microsecond: {_, precision}} = datetime
    {:ok, time} = Time.new(0, 0, 0, {0, precision})
    {:ok, date} = Date.new(year, month, 1)
    {:ok, datetime} = DateTime.new(date, time, time_zone, get_time_zone_datebase())
    datetime
  end

  @doc """
  Compares two `DateTime` or `NaiveDateTime` structs.

  ## Examples

    iex> compare(~N[2023-09-24 09:30:30], ~U[2023-09-24 09:30:31Z])
    :lt
    iex> compare(~N[2023-09-24 09:30:30], ~N[2023-09-24 09:30:29])
    :gt
    iex> compare(~U[2023-09-24 09:30:30Z], ~U[2023-09-24 09:30:30Z])
    :eq
  """
  @spec compare(Cocktail.time(), Cocktail.time()) :: :lt | :eq | :gt
  def compare(%NaiveDateTime{} = a, b) do
    NaiveDateTime.compare(a, b)
  end

  def compare(%DateTime{} = a, %DateTime{} = b) do
    DateTime.compare(a, b)
  end

  @doc """
  Convert a date/time value and timezone name to a DateTime struct.

    ## Examples

      iex> to_datetime(~N[2023-09-24 09:30:30], "America/New_York")
      #DateTime<2023-09-24 09:30:30-04:00 EDT America/New_York>
      iex> to_datetime(~U[2023-09-24 09:30:30Z], "America/New_York")
      #DateTime<2023-09-24 05:30:30-04:00 EDT America/New_York>
      iex> to_datetime(~U[2023-09-24 09:20:00Z], "invalid")
      {:error, {:invalid_timezone, "invalid"}}
      iex> to_datetime(~N[2023-09-24 09:30:30], "invalid")
      {:error, {:invalid_timezone, "invalid"}}
  """
  @spec to_datetime(Cocktail.time(), String.t()) :: DateTime.t() | {:error, {:invalid_timezone, String.t()}}
  def to_datetime(%NaiveDateTime{} = datetime, zone) do
    case DateTime.from_naive(datetime, zone, get_time_zone_datebase()) do
      {:ok, datetime} -> datetime
      {:error, :time_zone_not_found} -> {:error, {:invalid_timezone, zone}}
    end
  end

  def to_datetime(%DateTime{} = datetime, zone) do
    case DateTime.shift_zone(datetime, zone, get_time_zone_datebase()) do
      {:ok, datetime} -> datetime
      {:error, :time_zone_not_found} -> {:error, {:invalid_timezone, zone}}
    end
  end

  @doc """
  Converts a `DateTime`, `NaiveDateTime`, `Date` or `Time` struct to an Erlang datetime tuple.

  ## Examples

    iex> to_erl(~N[2023-09-24 09:30:30])
    {{2023, 9, 24}, {9, 30, 30}}
    iex> to_erl(~U[2023-09-24 09:30:30Z])
    {{2023, 9, 24}, {9, 30, 30}}
    iex> to_erl(~D[2000-01-01])
    {2000, 1, 1}
    iex> to_erl(~T[09:30:30])
    {9, 30, 30}
  """
  @spec to_erl(Time.t() | Date.t() | DateTime.t() | NaiveDateTime.t()) :: :calendar.time() | :calendar.datetime()
  def to_erl(%Time{} = time), do: Time.to_erl(time)
  def to_erl(%Date{} = time), do: Date.to_erl(time)
  def to_erl(%DateTime{} = time), do: time |> DateTime.to_naive() |> to_erl()
  def to_erl(%NaiveDateTime{} = time), do: NaiveDateTime.to_erl(time)

  @doc """
  Converts a `Calendar.time/0` to a `Date` struct.

  ## Examples

    iex> to_date(~N[2020-01-01 09:30:30])
    ~D[2020-01-01]
    iex> to_date(~U[2020-01-01 09:30:30Z])
    ~D[2020-01-01]
  """
  @spec to_date(Cocktail.time()) :: Date.t()
  def to_date(%DateTime{} = datetime) do
    DateTime.to_date(datetime)
  end

  def to_date(%NaiveDateTime{} = datetime) do
    NaiveDateTime.to_date(datetime)
  end

  @doc """
  Parses a string into a `DateTime` or `Time` struct.

    ## Examples

      iex> parse("20230924T093030", "%Y%m%dT%H%M%S")
      {:ok, ~N[2023-09-24 09:30:30]}
      iex> parse("093030", "%H%M%S")
      {:ok, ~T[09:30:30]}
      iex> parse("0930", "%H%M%S")
      {:error, :invalid_format}
  """
  @spec parse(String.t(), String.t()) :: {:ok, NaiveDateTime.t() | Time.t()} | {:error, atom()}
  def parse(
        <<year::binary-size(4), month::binary-size(2), day::binary-size(2), "T", hour::binary-size(2),
          minute::binary-size(2), second::binary-size(2)>>,
        "%Y%m%dT%H%M%S"
      ) do
    [year, month, day, hour, minute, second]
    |> Enum.map(&String.to_integer/1)
    |> then(&apply(NaiveDateTime, :new, &1))
  end

  def parse(<<hour::binary-size(2), minute::binary-size(2), second::binary-size(2)>>, "%H%M%S") do
    [hour, minute, second]
    |> Enum.map(&String.to_integer/1)
    |> then(&apply(Time, :new, &1))
  end

  def parse(_, _), do: {:error, :invalid_format}

  defp get_time_zone_datebase do
    Application.get_env(:elixir, :time_zone_database)
  end
end
