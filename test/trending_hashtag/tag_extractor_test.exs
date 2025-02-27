defmodule TagExtractorTest do
  use ExUnit.Case

  test "extracts tags from facets" do
    map = %{
      "commit" => %{
        "record" => %{
          "facets" => [
            %{
              "features" => [
                %{"$type" => "app.bsky.richtext.facet#tag", "tag" => "cavepaintings"}
              ],
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

  test "empty map works" do
    map = %{}
    assert TagExtractor.extract_tags(map) == []
  end

  test "tags get ordered correctly" do
    input = [{"a", 1}, {"c", 1}, {"b", 1}]
    assert [{"a", 1}, {"b", 1}, {"c", 1}] == Enum.sort(input, &TagExtractor.tag_cmp/2)
    input = [{"a", 2}, {"a", 0}, {"a", 1}]
    assert [{"a", 2}, {"a", 1}, {"a", 0}] == Enum.sort(input, &TagExtractor.tag_cmp/2)
  end
end
