defmodule HomeBot.DataStore do
  @moduledoc "Public interface for Data Stores"

  alias HomeBot.DataStore.ChannelStore
  alias HomeBot.DataStore.EnergyStore
  alias HomeBot.DataStore.TemperatureStore

  def add_subscriber(channel_id) do
    ChannelStore.add_subscriber(channel_id)
  end

  def get_subscribers do
    ChannelStore.get_subscribers()
  end

  def create_temperature_database_if_not_exists do
    TemperatureStore.create_database_if_not_exists()
  end

  def write_temperature_data(data) do
    TemperatureStore.write_temperature_data(data)
  end

  def get_latest_weather_data do
    TemperatureStore.get_latest_weather_data()
  end

  def get_latest_energy_measurement do
    EnergyStore.get_latest_measurement()
  end

  def get_gas_usage_per_hour do
    EnergyStore.get_gas_usage_per_hour()
  end

  def get_gas_usage_per_day do
    EnergyStore.get_gas_usage_per_day()
  end
end
