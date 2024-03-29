defmodule HomeSolar.SolarEdge.GetSolarEdgeTelemetryDataJob do
  alias HomeSolar.SolarEdge.ApiClient
  alias HomeSolar.SolarEdge.MqttPublisher

  # This job will run every hour and retrieve all telemetry data of the current day
  def run() do
    today = Date.utc_today() |> Date.to_string()
    start_time = NaiveDateTime.from_iso8601!(today <> " 00:00:00")

    tomorrow = Date.utc_today() |> Date.add(1) |> Date.to_string()
    end_time = NaiveDateTime.from_iso8601!(tomorrow <> " 00:00:00")
    now = Timex.now("Europe/Amsterdam") |> DateTime.to_naive()

    ApiClient.get_telemetry_data(start_time, end_time)
    |> Enum.filter(fn value -> value.timestamp < now end)
    |> then(&MqttPublisher.publish_telemetry_data/1)
  end
end
