defmodule SlidingWindowCounterTest do
  use ExUnit.Case

  test "counts correctly" do
    tags = ["1", "2", "2", "3", "3", "3"]

    slidingWindowCounter = SlidingWindowCounter.new(6)

    slidingWindowCounter =
      Enum.reduce(tags, slidingWindowCounter, fn tag, counter ->
        SlidingWindowCounter.add(counter, tag)
      end)

    assert {6, %{"3" => 3, "2" => 2, "1" => 1}} == SlidingWindowCounter.get_elements(slidingWindowCounter)

    slidingWindowCounter =
      Enum.reduce(tags, slidingWindowCounter, fn tag, counter ->
        SlidingWindowCounter.add(counter, tag)
      end)

    assert {6, %{"3" => 3, "2" => 2, "1" => 1}} == SlidingWindowCounter.get_elements(slidingWindowCounter)
  end
end
