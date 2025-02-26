defmodule TrendingHashtag.SfwCache do
  @moduledoc false
  use GenServer

  alias TrendingHashtag.TrendingHashtag

  @interval 1

  @ets_key "SFW"
  defp flush, do: Process.send_after(self(), :flush, @interval)

  def init(_) do
    :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    :ets.insert(__MODULE__, {@ets_key, {Time.utc_now(), []}})
    flush()

    {:ok, []}
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get do
    [{@ets_key, value}] = :ets.lookup(__MODULE__, @ets_key)
    value
  end

  def handle_info(:flush, _state) do
    {_size, map} = GenServer.call(TrendingHashtag, :get, 3000)
    tag_value_list = map |> Map.to_list() |> Enum.sort(fn {_k1, v1}, {_k2, v2} -> v1 >= v2 end)
    tag_list = Enum.map(tag_value_list, fn {k, _v} -> k end)

    if tag_list == [] do
      flush()
      {:noreply, []}
    else
      results = Nx.Serving.batched_run(NsfwClassifier, tag_list)

      sfw_tags =
        tag_value_list
        |> Stream.zip(results)
        |> Stream.filter(fn {_tag, %{predictions: predictions}} ->
          top_prediction = Enum.at(predictions, 0)
          top_prediction.label == "safe" && top_prediction.score > 0.6
        end)
        |> Stream.map(fn {tag, _} -> tag end)
        |> Stream.take(10)
        |> Enum.to_list()

      :ets.insert(__MODULE__, {@ets_key, {Time.utc_now(), sfw_tags}})
      flush()
      {:noreply, []}
    end
  end
end
