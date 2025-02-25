defmodule TagExtractor do
  @moduledoc false
  def extract_tags(map) do
    if match?(%{"commit" => %{"record" => %{"facets" => _}}}, map) do
      map
      |> get_in(["commit", "record", "facets"])
      |> Enum.flat_map(fn facet ->
        facet["features"]
        |> Enum.filter(&(&1["$type"] == "app.bsky.richtext.facet#tag"))
        |> Enum.map(& &1["tag"])
      end)
    else
      []
    end
  end
end
