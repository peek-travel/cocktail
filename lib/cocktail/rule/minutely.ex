defmodule Cocktail.Rule.Minutely do
  alias Cocktail.Validation.{Interval, ScheduleLock}

  def build_validations(options) do
    interval = Keyword.get(options, :interval, 1)

    [
      base_sec: [ ScheduleLock.new(:second) ],
      interval: [ Interval.new(:minutely, interval) ]
    ]
  end
end
