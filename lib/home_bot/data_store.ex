defmodule HomeBot.DataStore do
  @moduledoc "Public interface for Data Stores"

  alias HomeBot.DataStore.ChannelStore
  alias HomeBot.DataStore.EnergyStore
  alias HomeBot.DataStore.TemperatureStore
  alias HomeBot.DataStore.EnergyPostgresStore

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

  def get_average_temperature_per_day(days \\ 48) do
    TemperatureStore.get_average_temperature_per_day(days)
  end

  def get_average_temperature(start_time, end_time) do
    TemperatureStore.get_average_temperature(start_time, end_time)
  end

  def get_latest_energy_measurement do
    EnergyPostgresStore.get_latest_measurement()
  end

  def get_measurements_since(timestamp) do
    EnergyStore.get_measurements_since(timestamp)
  end

  def get_gas_usage(group, start_time, end_time) do
    EnergyStore.get_gas_usage(group, start_time, end_time)
  end

  def get_gas_usage_per_hour(days \\ 48) do
    EnergyStore.get_gas_usage_per_hour(days)
  end

  def get_gas_usage_per_day(days \\ 48) do
    EnergyStore.get_gas_usage_per_day(days)
  end

  def get_electricity_usage(group, start_time, end_time) do
    EnergyStore.get_electricity_usage(group, start_time, end_time)
  end

  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(map())
  def get_energy_usage(start_time, end_time, group_unit, group_quantity) do
    EnergyPostgresStore.get_energy_usage(start_time, end_time, group_unit, group_quantity)
  end

  def get_electricity_usage_per_hour(days \\ 3) do
    EnergyStore.get_electricity_usage_per_hour(days)
  end

  def get_electricity_usage_per_day(days \\ 48) do
    EnergyStore.get_electricity_usage_per_day(days)
  end

  def get_electricity_usage(minutes \\ 3) do
    EnergyPostgresStore.get_electricity_usage(minutes)
  end

  def get_current_home_temperature do
    HomeBot.DataStore.HomeClimateStore.get_latest_temperature()
  end

  def get_current_home_humidity do
    HomeBot.DataStore.HomeClimateStore.get_latest_humidity()
  end

  def get_recent_home_climate_data do
    HomeBot.DataStore.HomeClimateStore.get_recent_home_climate_data()
  end
end
