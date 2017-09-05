defmodule Cocktail do
  @moduledoc """
  TODO: write module doc
  """

  alias Cocktail.Schedule

  @type frequency :: :yearly   |
                     :monthly  |
                     :weekly   |
                     :daily    |
                     :hourly   |
                     :minutely |
                     :secondly

  @type day_number :: 0..6

  @type day_atom :: :monday    |
                    :tuesday   |
                    :wednesday |
                    :thursday  |
                    :friday    |
                    :saturday  |
                    :sunday

  @type day :: day_number | day_atom

  @type hour_number :: 0..23

  @type schedule_option :: {:duration, pos_integer}

  @type schedule_options :: [schedule_option]

  @type rule_option :: {:frequency, frequency}  |
                       {:interval, pos_integer} |
                       {:count, pos_integer}    |
                       {:until, DateTime.t}     |
                       {:days, [day]}    |
                       {:hours, [hour_number]}

  @type rule_options :: [rule_option]

  @doc """
  TODO: write short description

  see `Cocktail.Schedule.new/1`
  """
  @spec schedule(DateTime.t, schedule_options) :: Schedule.t
  def schedule(start_time, options \\ []), do: Schedule.new(start_time, options)
end
