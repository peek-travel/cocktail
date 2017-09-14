defmodule Cocktail.Test do
  use ExUnit.Case

  test "schedule" do
    assert Cocktail.schedule(~N[2017-01-01 09:00:00], duration: 3_600)
  end
end
