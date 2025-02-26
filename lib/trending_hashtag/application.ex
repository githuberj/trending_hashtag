defmodule TrendingHashtag.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TrendingHashtagWeb.Telemetry,
      TrendingHashtag.Repo,
      {DNSCluster, query: Application.get_env(:trending_hashtag, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: TrendingHashtag.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: TrendingHashtag.Finch},
      # Start a worker by calling: TrendingHashtag.Worker.start_link(arg)
      # {TrendingHashtag.Worker, arg},
      # Start to serve requests, typically the last entry
      %{
        id: TrendingHashtag.JetstreamClient,
        start: {TrendingHashtag.JetstreamClient, :start_link, []}
      },
      %{
        id: TrendingHashtag.TrendingHashtag,
        start: {TrendingHashtag.TrendingHashtag, :start_link, []}
      },
      {Nx.Serving,
       serving: TrendingHashtag.NsfwClassifier.serving(),
       name: NsfwClassifier,
       batch_size: 10,
       batch_timeout: 100,
       partitions: true},
      %{id: TrendingHashtag.SfwCache, start: {TrendingHashtag.SfwCache, :start_link, []}},
      TrendingHashtagWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TrendingHashtag.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TrendingHashtagWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
