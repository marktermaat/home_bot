defmodule HomeBot.DataStore do
  def add_subscriber(channel_id) do
    HomeBot.DataStore.ChannelStore.add_subscriber(channel_id)
  end

  def get_subscribers() do
    HomeBot.DataStore.ChannelStore.get_subscribers()
  end

  def create_temperature_database_if_not_exists() do
    HomeBot.DataStore.TemperatureStore.create_database_if_not_exists()
  end

  def write_temperature_data(data) do
    HomeBot.DataStore.TemperatureStore.write_temperature_data(data)
  end

  def get_latest_temperature() do
    HomeBot.DataStore.TemperatureStore.get_latest_temperature()
  end
end
