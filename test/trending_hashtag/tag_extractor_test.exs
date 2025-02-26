defmodule TagExtractorTest do
  use ExUnit.Case

  test "extracts tags from facets" do
    map = %{
      "commit" => %{
        "record" => %{
          "facets" => [
            %{
              "features" => [%{"$type" => "app.bsky.richtext.facet#tag", "tag" => "cavepaintings"}],
              "index" => %{"byteEnd" => 284, "byteStart" => 270}
            },
            %{
              "features" => [%{"$type" => "app.bsky.richtext.facet#tag", "tag" => "Lascaux"}],
              "index" => %{"byteEnd" => 293, "byteStart" => 285}
            },
            %{
              "features" => [],
              "index" => %{"byteEnd" => 293, "byteStart" => 285}
            }
          ]
        }
      }
    }

    assert TagExtractor.extract_tags(map) == ["cavepaintings", "Lascaux"]
  end

  test "empty map does not break the code" do
    map = %{}
    assert TagExtractor.extract_tags(map) == []
  end
end
