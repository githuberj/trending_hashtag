defmodule TrendingHashtagWeb.TrendingLive do
  @moduledoc false
  use TrendingHashtagWeb, :live_view
  alias TrendingHashtag.PostCounter
  alias TrendingHashtag.TrendingHashtag

  @interval 200

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      LiveView Bluesky Trending Hashtags Dashboard
      <:subtitle>The Live Bluesky Feed</:subtitle>
    </.header>

    <h4>Current window size: {@size}</h4>
    <h4>Total posts: {@posts_count}</h4>

    <table class="w-full border border-gray-200 rounded-lg">
      <thead class="bg-gray-100">
        <tr>
          <th class="text-left p-2 border-b">Tag Name</th>
          <th class="text-right p-2 border-b">Count</th>
        </tr>
      </thead>
      <tbody id="tagTableBody">
        <%= for {name, value} <- @tags do %>
          <tr>
            <td class="text-left p-2 border-b font-medium">{name}</td>
            <td class="text-right p-2 border-b text-gray-600">{value}</td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    flush()

    {:ok, socket |> assign(:tags, []) |> assign(:size, 0) |> assign(:posts_count, 0)}
  end

  @impl Phoenix.LiveView
  def handle_info(:flush, socket) do
    flush()

    {size, map} = GenServer.call(TrendingHashtag, :get, 3000)
    posts_count = GenServer.call(PostCounter, :get, 3000)

    socket =
      socket
      |> assign(
        :tags,
        map
        |> Enum.sort(&TagExtractor.tag_cmp/2)
        |> Enum.take(50)
      )
      |> assign(:size, size)
      |> assign(:posts_count, posts_count)

    {:noreply, socket}
  end

  defp flush, do: Process.send_after(self(), :flush, @interval)
end
