defmodule Intercambio.State do
  alias Intercambio.Persist
  require Logger
  use GenServer

  defstruct [
    :gtfs_feed_url,
    :interval,
    :alerts,
    :translated_alerts
  ]

  def child_spec(opts) do
    {spec_id, opts} = Keyword.pop!(opts, :spec_id)

    %{
      id: spec_id,
      start: {__MODULE__, :start_link, [opts]}
    }
  end

  defp fetch_alerts(gtfs_feed_url) do
    {:ok, %Req.Response{body: alerts_json}} = Req.get(gtfs_feed_url)
    alerts_json
  end

  @impl true
  def init(opts) do
    interval = Keyword.fetch!(opts, :interval)
    gtfs_feed_url = Keyword.fetch!(opts, :gtfs_feed_url)

    send(self(), :init)

    {:ok,
     %__MODULE__{
       interval: interval,
       gtfs_feed_url: gtfs_feed_url
     }}
  end

  @impl true
  def handle_info(:init, %{interval: interval, gtfs_feed_url: gtfs_feed_url} = state) do
    alerts = fetch_alerts(gtfs_feed_url)
    {:noreply, %{state | alerts: alerts}, interval}
  end

  def handle_info(:timeout, %{gtfs_feed_url: gtfs_feed_url, interval: interval} = state) do
    alerts = fetch_alerts(gtfs_feed_url)
    translated_alerts = 
      alerts 
      |> Intercambio.Alert.add_translations_to_alerts()

    Persist.write_json_to_file(translated_alerts, "Alerts.json") 

    {:noreply, %{state | alerts: alerts, translated_alerts: translated_alerts}, interval}
  end

  def start_link(init_arg) do
    GenServer.start_link(__MODULE__, init_arg)
  end

  @spec stop(pid()) :: :ok
  def stop(pid) do
    GenServer.stop(pid)
  end
end
