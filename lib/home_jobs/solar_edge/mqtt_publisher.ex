defmodule HomeJobs.SolarEdge.MqttPublisher do
  alias HomeJobs.SolarEdge.EnergyValue
  alias HomeJobs.SolarEdge.EnergyDayValue

  @spec publish_quarter_energy_data([%EnergyValue{}]) :: :ok
  def publish_quarter_energy_data(records) do
    records
    |> Enum.map(&Jason.encode!/1)
    |> Enum.each(fn message ->
      Tortoise.publish("HomeBot", "data/solar/quarter_energy", message, qos: 1)
    end)
  end

  @spec publish_daily_energy_data([%EnergyDayValue{}]) :: :ok
  def publish_daily_energy_data(records) do
    records
    |> Enum.map(&Jason.encode!/1)
    |> Enum.each(fn message ->
      Tortoise.publish("HomeBot", "data/solar/daily_energy", message, qos: 1)
    end)
  end
end
