defmodule Intercambio.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Intercambio.Worker.start_link(arg)
      # {Intercambio.Worker, arg}
      {Intercambio.GtfsRealTimeFetcher, spec_id: :fetcher, interval: 10_000, gtfs_feed_url: "https://cdn.mbta.com/realtime/Alerts.json"}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Intercambio.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
