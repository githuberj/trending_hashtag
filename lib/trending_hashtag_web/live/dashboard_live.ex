defmodule TrendingHashtagWeb.DashboardLive do
  @moduledoc false
  use TrendingHashtagWeb, :live_view

  alias TrendingHashtag.TrendingHashtag

  @interval 100

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      LiveView Bluesky Trending Hashtags Dashboard
      <:subtitle>The Live Bluesky Feed</:subtitle>
    </.header>

    <h4>Current window size: {@size}</h4>

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

    {:ok, socket |> assign(:tags, []) |> assign(:size, 0)}
  end

  @impl Phoenix.LiveView
  def handle_info(:flush, socket) do
    flush()

    {size, map} = GenServer.call(TrendingHashtag, :get, 3000)

    socket =
      socket
      |> assign(
        :tags,
        map
        |> Enum.sort(fn {_k1, v1}, {_k2, v2} -> v1 >= v2 end)
        |> Enum.take(15)
      )
      |> assign(:size, size)

    {:noreply, socket}
  end

  defp flush, do: Process.send_after(self(), :flush, @interval)
end
