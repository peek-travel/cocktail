defmodule Cocktail.Rule.Secondly do
  alias Cocktail.Validation.Interval

  def build_validations(options) do
    interval = Keyword.get(options, :interval, 1)

    [ interval: [ Interval.new(:secondly, interval) ] ]
  end
end
