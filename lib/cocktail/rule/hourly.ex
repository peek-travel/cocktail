defmodule Cocktail.Rule.Hourly do
  alias Cocktail.Validation.{Interval, ScheduleLock}

  def build_validations(options) do
    interval = Keyword.get(options, :interval, 1)

    [
      base_sec: [ ScheduleLock.new(:second) ],
      base_min: [ ScheduleLock.new(:minute) ],
      interval: [ Interval.new(:hourly, interval) ]
    ]
  end
end
