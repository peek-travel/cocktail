defmodule Cocktail.SpanTest do
  use ExUnit.Case

  alias Cocktail.Span

  doctest Cocktail.Span, import: true

  test "contains" do
    span1 = Span.new(~N[2017-09-09 09:00:00], ~N[2017-09-09 12:00:00])
    span2 = Span.new(~N[2017-09-09 10:00:00], ~N[2017-09-09 11:00:00])

    assert Span.overlap_mode(span1, span2) == :contains
  end

  test "is_inside" do
    span1 = Span.new(~N[2017-09-09 10:00:00], ~N[2017-09-09 11:00:00])
    span2 = Span.new(~N[2017-09-09 09:00:00], ~N[2017-09-09 12:00:00])

    assert Span.overlap_mode(span1, span2) == :is_inside
  end

  test "is_before" do
    span1 = Span.new(~N[2017-09-09 09:00:00], ~N[2017-09-09 10:00:00])
    span2 = Span.new(~N[2017-09-09 11:00:00], ~N[2017-09-09 12:00:00])

    assert Span.overlap_mode(span1, span2) == :is_before
  end

  test "is_after" do
    span1 = Span.new(~N[2017-09-09 11:00:00], ~N[2017-09-09 12:00:00])
    span2 = Span.new(~N[2017-09-09 09:00:00], ~N[2017-09-09 10:00:00])

    assert Span.overlap_mode(span1, span2) == :is_after
  end

  test "overlaps_the_start_of" do
    span1 = Span.new(~N[2017-09-09 09:00:00], ~N[2017-09-09 11:00:00])
    span2 = Span.new(~N[2017-09-09 10:00:00], ~N[2017-09-09 12:00:00])

    assert Span.overlap_mode(span1, span2) == :overlaps_the_start_of
  end

  test "overlaps_the_end_of" do
    span1 = Span.new(~N[2017-09-09 10:00:00], ~N[2017-09-09 12:00:00])
    span2 = Span.new(~N[2017-09-09 09:00:00], ~N[2017-09-09 11:00:00])

    assert Span.overlap_mode(span1, span2) == :overlaps_the_end_of
  end
end
