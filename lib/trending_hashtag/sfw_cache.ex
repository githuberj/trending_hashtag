defmodule TrendingHashtag.SfwCache do
  @moduledoc false
  use GenServer

  alias TrendingHashtag.TrendingHashtag

  @interval 100

  @ets_key "SFW"
  defp flush, do: Process.send_after(self(), :flush, @interval)

  def init(_) do
    :ets.new(__MODULE__, [:named_table, read_concurrency: true])
    :ets.insert(__MODULE__, {@ets_key, {Time.utc_now(), []}})
    table = :ets.new(:inference_cache, [:set])
    flush()

    {:ok, table}
  end

  def start_link do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def get do
    [{@ets_key, value}] = :ets.lookup(__MODULE__, @ets_key)
    value
  end

  def handle_info(:flush, table) do
    {_size, map} = GenServer.call(TrendingHashtag, :get, 3000)

    tag_value_list =
      map
      |> Map.to_list()
      |> Enum.sort(&TagExtractor.tag_cmp/2)
      |> Enum.take(40)

    if tag_value_list == [] do
      flush()
      {:noreply, table}
    else
      {safe, unknown} =
        Enum.reduce(tag_value_list, {[], []}, fn {k, v}, {safe, unknown} ->
          pair = :ets.lookup(table, k)

          case pair do
            [{^k, "safe"}] ->
              {[{k, v} | safe], unknown}

            [{^k, "unsafe"}] ->
              {[{k, "unsafe"} | safe], unknown}

            [] ->
              {safe, [k | unknown]}

            _ ->
              {safe, unknown}
          end
        end)

      unknown = Enum.reverse(unknown) |> Enum.take(3)
      safe = Enum.reverse(safe) |> Enum.take(15)

      if unknown != [] do
        Nx.Serving.batched_run(NsfwClassifier, unknown)
        |> Enum.zip(unknown)
        |> Enum.map(fn {%{predictions: predictions}, tag} ->
          top_prediction = Enum.at(predictions, 0)

          if top_prediction.label == "safe" && top_prediction.score > 0.6 do
            {tag, "safe"}
          else
            {tag, "unsafe"}
          end
        end)
        |> Enum.map(fn result ->
          :ets.insert(table, result)
        end)
      end

      :ets.insert(__MODULE__, {@ets_key, {Time.utc_now(), safe}})
      flush()
      {:noreply, table}
    end
  end
end
