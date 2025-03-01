defmodule TrendingHashtag.PostCounter do
  @moduledoc false
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def init(_) do
    :ok = Phoenix.PubSub.subscribe(TrendingHashtag.PubSub, "firehose", link: true)
    {:ok, 0}
  end

  def handle_info({:frame, _json_map}, count) do
    {:noreply, count + 1}
  end

  def handle_call(:get, _from, count) do
    {:reply, count, count}
  end
end
