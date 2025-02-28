defmodule TrendingHashtag.TrendingHashtag do
  @moduledoc false
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    Phoenix.PubSub.subscribe(TrendingHashtag.PubSub, "firehose")
    {:ok, SlidingWindowCounter.new(10_000)}
  end

  def handle_info({:frame, json_map}, %SlidingWindowCounter{} = state) do
    state =
      json_map
      |> TagExtractor.extract_tags()
      |> Enum.reduce(state, fn e, state ->
        SlidingWindowCounter.add(state, e)
      end)

    {:noreply, state}
  end

  def handle_call(:get, _from, state) do
    {:reply, SlidingWindowCounter.get_elements(state), state}
  end
end
