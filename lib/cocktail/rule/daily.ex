defmodule Cocktail.Rule.Daily do
  alias Cocktail.Validation.{Interval, ScheduleLock}

  def build_validations(options) do
    interval = Keyword.get(options, :interval, 1)

    [
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ],
      base_hour: [ ScheduleLock.new(:hour) ],
      interval: [ Interval.new(:daily, interval) ]
    ]
  end
end
