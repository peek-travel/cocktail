defmodule CocktailTest do
  use ExUnit.Case
  doctest Cocktail

  alias Cocktail.Schedule

  test "create a schedule with a daily recurrence rule" do
    schedule =
      Cocktail.schedule
      |> Schedule.add_recurrence_rule(:daily)

    assert schedule == %Cocktail.Schedule{recurrence_rules: [%Cocktail.Rules.Daily{}]}
  end
end
