defmodule Intercambio.Persist do
  def write_json_to_file(alerts_feed, file_name) do
    alerts_json = Jason.encode!(alerts_feed)
    File.write!(file_name, alerts_json)
  end
end
