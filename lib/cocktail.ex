defmodule Cocktail do
  @moduledoc """
  Top level types and convenience functions.

  This module holds some top-level types and a convenience function for
  creating a new schedule. Details available in the `Cocktail.Schedule` module.
  """

  alias Cocktail.{Schedule, Span}

  @type frequency :: :monthly | :weekly | :daily | :hourly | :minutely | :secondly

  @type day_number :: 0..6
  @type day_of_month :: -31..-1 | 1..31

  @type day_atom :: :monday | :tuesday | :wednesday | :thursday | :friday | :saturday | :sunday

  @type day :: day_number | day_atom

  @type hour_number :: 0..23

  @type minute_number :: 0..59

  @type second_number :: 0..59

  @type time_range :: %{
          start_time: Time.t(),
          end_time: Time.t(),
          interval_seconds: second_number()
        }

  @type schedule_option :: {:duration, pos_integer}

  @type schedule_options :: [schedule_option]

  @type rule_option ::
          {:frequency, frequency}
          | {:interval, pos_integer}
          | {:count, pos_integer}
          | {:until, time}
          | {:days, [day]}
          | {:days_of_month, [day_of_month]}
          | {:hours, [hour_number]}
          | {:minutes, [minute_number]}
          | {:seconds, [second_number]}
          | {:times, [Time.t()]}
          | {:time_range, time_range}

  @type rule_options :: [rule_option]

  @type time :: DateTime.t() | NaiveDateTime.t()

  @type occurrence :: time | Span.t()

  @doc """
  Creates a new schedule using the given start time and options.

  see `Cocktail.Schedule.new/1` for details.
  """
  @spec schedule(time, schedule_options) :: Schedule.t()
  def schedule(start_time, options \\ []), do: Schedule.new(start_time, options)
end
