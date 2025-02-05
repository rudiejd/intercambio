defmodule Intercambio.InformedEntity do
  defstruct([
    :trip_id,
    :route_type,
    :route_id,
    :direction_id,
    :stop_id,
    activities: ["BOARD", "EXIT", "RIDE"]
  ])
end
