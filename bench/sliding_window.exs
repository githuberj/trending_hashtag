slidingWindow = SlidingWindowCounter.new(10000)

Benchee.run(
  %{
    "slidingWindow 1k" => fn ->
      Enum.reduce(Enum.to_list(1..1000), slidingWindow, fn e, window ->
        SlidingWindowCounter.add(window, e)
      end)
    end,
    "slidingWindow 10k" => fn ->
      Enum.reduce(Enum.to_list(1..10_000), slidingWindow, fn e, window ->
        SlidingWindowCounter.add(window, e)
      end)
    end,
    "slidingWindow 100k" => fn ->
      Enum.reduce(Enum.to_list(1..100_000), slidingWindow, fn e, window ->
        SlidingWindowCounter.add(window, e)
      end)
    end
  },
  time: 10,
  memory_time: 2
)
