defmodule HomeJobs.SolarEdge.GetSolarEdgeQuarterDataJob do
  alias HomeJobs.SolarEdge.ApiClient
  alias HomeJobs.SolarEdge.MqttPublisher 

  # This job will run every 15 minutes and retrieve all quarter data of the last 2 days
  def run() do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)

    ApiClient.get_quarter_energy_data(yesterday, today)
    |> Enum.filter(fn value -> value.timestamp < NaiveDateTime.utc_now() end)
    |> then(&MqttPublisher.publish_energy_data/1)
  end
end
