defmodule TrendingHashtagWeb.HomeLive do
  @moduledoc false
  use TrendingHashtagWeb, :live_view

  @interval 100

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <.header>
      LiveView TrendingHashtag
      <:subtitle>The Live Bluesky Feed</:subtitle>
    </.header>

    <div>Posts per second {@posts_per_second}</div>

    <div id="feed" phx-update="stream" class="flex flex-col gap-y-4">
      <div :for={{id, {_id, frame}} <- @streams.frames} id={id}>
        {frame}
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(TrendingHashtag.PubSub, "firehose")

    socket =
      socket
      |> stream_configure(:frames, dom_id: &elem(&1, 0))
      |> stream(:frames, [], limit: 50)
      |> assign(:buffer, [])
      |> assign(:start, Time.utc_now())
      |> assign(:posts_per_second, 0)
      |> assign(:number_of_posts, 0)

    flush()

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_info({:frame, json_map}, socket) do
    id = json_map["commit"]["cid"]

    json =
      json_map
      |> Jason.encode!()
      |> Jason.Formatter.pretty_print()

    diff = max(1, Time.diff(Time.utc_now(), socket.assigns[:start], :second))

    socket =
      update(socket, :buffer, &[{id, json} | &1])
      |> update(:number_of_posts, fn c -> c + 1 end)
      |> assign(:posts_per_second, socket.assigns[:number_of_posts] / diff)

    {:noreply, socket}
  end

  def handle_info(:flush, socket) do
    %{buffer: buffer} = socket.assigns

    socket =
      socket
      |> assign(:buffer, [])
      |> stream(:frames, Enum.reverse(buffer), at: 0, limit: 50)

    flush()

    {:noreply, socket}
  end

  defp flush, do: Process.send_after(self(), :flush, @interval)
end
