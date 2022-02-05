defmodule HomeJobs.SolarEdge.MqttPublisher do
  alias HomeJobs.SolarEdge.EnergyValue
  alias HomeJobs.SolarEdge.EnergyDayValue
  alias HomeJobs.SolarEdge.TelemetryValue

  @spec publish_quarter_energy_data([%EnergyValue{}]) :: :ok
  def publish_quarter_energy_data(records) do
    records
    |> Enum.map(&Jason.encode!/1)
    |> Enum.each(fn message ->
      Tortoise.publish(client_id(), "data/solar/quarter_energy", message, qos: 1)
    end)
  end

  @spec publish_daily_energy_data([%EnergyDayValue{}]) :: :ok
  def publish_daily_energy_data(records) do
    records
    |> Enum.map(&Jason.encode!/1)
    |> Enum.each(fn message ->
      Tortoise.publish(client_id(), "data/solar/daily_energy", message, qos: 1)
    end)
  end

  @spec publish_telemetry_data([%TelemetryValue{}]) :: :ok
  def publish_telemetry_data(records) do
    records
    |> Enum.map(&Jason.encode!/1)
    |> Enum.each(fn message ->
      Tortoise.publish(client_id(), "data/solar/telemetry", message, qos: 1)
    end)
  end

  def client_id, do: Application.fetch_env!(:home_bot, :mqtt_client_id)
end
