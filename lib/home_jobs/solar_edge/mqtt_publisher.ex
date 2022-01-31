defmodule HomeJobs.SolarEdge.MqttPublisher do
  alias HomeJobs.SolarEdge.EnergyValue

  @spec publish_energy_data([%EnergyValue{}]) :: :ok
  def publish_energy_data(records) do
    records
    |> Enum.map(&Jason.encode!/1)
    |> Enum.each(fn message ->
      Tortoise.publish("HomeBot", "data/solar/quarter_energy", message, qos: 1)
    end)
  end
end
