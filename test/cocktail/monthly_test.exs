defmodule Cocktail.MonthlyTest do
  use ExUnit.Case

  alias Cocktail.Schedule

  import Cocktail.TestSupport.DateTimeSigil

  @spec first_n_occurrences(Cocktail.Schedule.t(), integer()) :: term
  def first_n_occurrences(schedule, n \\ 20) do
    schedule
    |> Cocktail.Schedule.occurrences()
    |> Enum.take(n)
  end

  @spec assert_icalendar_preserved(Cocktail.Schedule.t()) :: Cocktail.Schedule.t()
  defp assert_icalendar_preserved(schedule) do
    {:ok, preserved_schedule} =
      schedule
      |> Cocktail.Schedule.to_i_calendar()
      |> Cocktail.Schedule.from_i_calendar()

    assert first_n_occurrences(schedule) == first_n_occurrences(preserved_schedule)
  end

  test "Monthly" do
    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-01-01 06:00:00 UTC],
             ~Y[2017-02-01 06:00:00 UTC],
             ~Y[2017-03-01 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Monthly starting on 31th January 2017" do
    schedule =
      ~N[2017-01-31 09:00:00]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)

    assert first_n_occurrences(schedule, 10) == [
             ~N[2017-01-31 09:00:00],
             ~N[2017-03-31 09:00:00],
             ~N[2017-05-31 09:00:00],
             ~N[2017-07-31 09:00:00],
             ~N[2017-08-31 09:00:00],
             ~N[2017-10-31 09:00:00],
             ~N[2017-12-31 09:00:00],
             ~N[2018-01-31 09:00:00],
             ~N[2018-03-31 09:00:00],
             ~N[2018-05-31 09:00:00]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Monthly starting on 31th March 2017" do
    schedule =
      ~Y[2017-03-31 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-03-31 06:00:00 UTC],
             ~Y[2017-05-31 06:00:00 UTC],
             ~Y[2017-07-31 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Monthly starting on 28th Feb 2017" do
    schedule =
      ~Y[2017-02-28 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-02-28 06:00:00 UTC],
             ~Y[2017-03-28 06:00:00 UTC],
             ~Y[2017-04-28 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "every 12 month starting on 29th Feb 2020" do
    schedule =
      ~Y[2020-02-29 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 12)

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2020-02-29 06:00:00 UTC],
             ~Y[2024-02-29 06:00:00 UTC],
             ~Y[2028-02-29 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Monthly: starting on 7th Nov 2019 and should return 7 th Nov 2039 after 20 years " do
    times =
      ~Y[2019-11-07 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)
      |> Cocktail.Schedule.occurrences()
      |> Enum.at(20 * 12)

    assert times == ~Y[2039-11-07 06:00:00 UTC]
  end

  test "Every 2 months" do
    schedule =
      ~Y[2017-02-28 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 2)

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-02-28 06:00:00 UTC],
             ~Y[2017-04-28 06:00:00 UTC],
             ~Y[2017-06-28 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Every 2 / 3 months" do
    schedule =
      ~Y[2017-01-02 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 2)
      |> Schedule.add_recurrence_rule(:monthly, interval: 3)

    assert first_n_occurrences(schedule, 7) == [
             ~Y[2017-01-02 06:00:00 UTC],
             ~Y[2017-03-02 06:00:00 UTC],
             ~Y[2017-04-02 06:00:00 UTC],
             ~Y[2017-05-02 06:00:00 UTC],
             ~Y[2017-07-02 06:00:00 UTC],
             ~Y[2017-09-02 06:00:00 UTC],
             ~Y[2017-10-02 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Monthly; overridden start month" do
    times =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly)
      |> Cocktail.Schedule.occurrences(~Y[2017-05-01 06:00:00 UTC])
      |> Enum.take(3)

    assert times == [
             ~Y[2017-05-01 06:00:00 UTC],
             ~Y[2017-06-01 06:00:00 UTC],
             ~Y[2017-07-01 06:00:00 UTC]
           ]
  end

  test "Monthly on Mondays and Fridays" do
    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days: [:monday, :friday])

    assert first_n_occurrences(schedule, 5) == [
             ~Y[2017-01-02 06:00:00 UTC],
             ~Y[2017-01-06 06:00:00 UTC],
             ~Y[2017-01-09 06:00:00 UTC],
             ~Y[2017-01-13 06:00:00 UTC],
             ~Y[2017-01-16 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Monthly on Mondays and Fridays and day of month" do
    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days: [:monday, :friday], days_of_month: [1])

    assert first_n_occurrences(schedule, 8) == [
             ~Y[2017-05-01 06:00:00 UTC],
             ~Y[2017-09-01 06:00:00 UTC],
             ~Y[2017-12-01 06:00:00 UTC],
             ~Y[2018-01-01 06:00:00 UTC],
             ~Y[2018-06-01 06:00:00 UTC],
             ~Y[2018-10-01 06:00:00 UTC],
             ~Y[2019-02-01 06:00:00 UTC],
             ~Y[2019-03-01 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Every month 11th day of the month" do
    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days_of_month: [11])

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-01-11 06:00:00 UTC],
             ~Y[2017-02-11 06:00:00 UTC],
             ~Y[2017-03-11 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Every month 31day of the month" do
    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days_of_month: [31])

    assert first_n_occurrences(schedule, 4) == [
             ~Y[2017-01-31 06:00:00 UTC],
             ~Y[2017-02-28 06:00:00 UTC],
             ~Y[2017-03-31 06:00:00 UTC],
             ~Y[2017-04-30 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "support negative for day of the month" do
    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days_of_month: [-11])

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-01-21 06:00:00 UTC],
             ~Y[2017-02-18 06:00:00 UTC],
             ~Y[2017-03-21 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Every other month 10th of the month and sunday:" do
    schedule =
      ~Y[2017-01-02 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, interval: 2, days_of_month: [10, 12], days: [:sunday, :saturday])

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-03-12 06:00:00 UTC],
             ~Y[2017-09-10 06:00:00 UTC],
             ~Y[2017-11-12 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Monthly on the 10th and 14th hours of the day" do
    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, hours: [10, 14])

    assert first_n_occurrences(schedule, 5) == [
             ~Y[2017-01-01 10:00:00 UTC],
             ~Y[2017-01-01 14:00:00 UTC],
             ~Y[2017-02-01 10:00:00 UTC],
             ~Y[2017-02-01 14:00:00 UTC],
             ~Y[2017-03-01 10:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Last Friday of every month" do
    days_of_month = [-1, -2, -3, -4, -5, -6, -7]

    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days: [:friday], days_of_month: days_of_month)

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-01-27 06:00:00 UTC],
             ~Y[2017-02-24 06:00:00 UTC],
             ~Y[2017-03-31 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "Last Friday of every month reversed" do
    days_of_month = [-1, -2, -3, -4, -5, -6, -7] |> Enum.reverse()

    schedule =
      ~Y[2017-01-01 06:00:00 UTC]
      |> Cocktail.schedule()
      |> Schedule.add_recurrence_rule(:monthly, days: [:friday], days_of_month: days_of_month)

    assert first_n_occurrences(schedule, 3) == [
             ~Y[2017-01-27 06:00:00 UTC],
             ~Y[2017-02-24 06:00:00 UTC],
             ~Y[2017-03-31 06:00:00 UTC]
           ]

    assert_icalendar_preserved(schedule)
  end

  test "a monthly schedule with a UTC datetime and a days of month option" do
    schedule =
      ~N[2021-02-28 06:00:00]
      |> Timex.to_datetime("UTC")
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(:monthly, days_of_month: [1])

    times = schedule |> Schedule.occurrences() |> Enum.take(2)

    assert times == [
             ~Y[2021-03-01 06:00:00 UTC],
             ~Y[2021-04-01 06:00:00 UTC]
           ]
  end

  test "a monthly schedule with a zoned datetime and a days of month option" do
    schedule =
      ~N[2021-02-28 06:00:00]
      |> Timex.to_datetime("America/Vancouver")
      |> Schedule.new()
      |> Schedule.add_recurrence_rule(:monthly, days_of_month: [1])

    times = schedule |> Schedule.occurrences() |> Enum.take(2)

    assert times == [
             ~Y[2021-03-01 06:00:00 America/Vancouver],
             ~Y[2021-04-01 06:00:00 America/Vancouver]
           ]
  end
end
