defmodule Cocktail.RuleTest do
  use ExUnit.Case

  alias Cocktail.Rule

  test "rules implement inspect" do
    rule = Rule.new(frequency: :daily, interval: 2)

    assert inspect(rule) == "#Cocktail.Rule<Every 2 days>"
  end
end
