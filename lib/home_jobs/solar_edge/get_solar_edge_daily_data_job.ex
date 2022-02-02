defmodule HomeJobs.SolarEdge.GetSolarEdgeDailyDataJob do
  alias HomeJobs.SolarEdge.ApiClient
  alias HomeJobs.SolarEdge.MqttPublisher 

  # This job will run every day and retrieve all daily data of the last 2 days
  def run() do
    start_date = Date.utc_today() |> Date.add(-2)
    end_date = Date.add(start_date, 1)

    ApiClient.get_daily_energy_data(start_date, end_date)
    |> then(&MqttPublisher.publish_daily_energy_data/1)
  end
end
