defmodule TrendingHashtagWeb.SfwTrendingLive do
  @moduledoc false
  use TrendingHashtagWeb, :live_view

  @interval 100

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      LiveView Bluesky Trending Safe for Work Hashtags Dashboard
      <:subtitle>The Live Bluesky Feed</:subtitle>
    </.header>

    <h4>Last update UTC: {@last_update}</h4>

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

    {:ok, socket |> assign(:tags, []) |> assign(:size, 0) |> assign(:last_update, "never")}
  end

  @impl Phoenix.LiveView
  def handle_info(:flush, socket) do
    {last_update, sfw_tags} = TrendingHashtag.SfwCache.get()

    socket =
      socket
      |> assign(
        :tags,
        sfw_tags
      )
      |> assign(:size, length(sfw_tags))
      |> assign(:last_update, last_update)

    flush()
    {:noreply, socket}
  end

  defp flush, do: Process.send_after(self(), :flush, @interval)
end
