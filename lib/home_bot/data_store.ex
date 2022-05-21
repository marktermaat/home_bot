defmodule HomeBot.DataStore do
  @moduledoc "Public interface for Data Stores"

  alias HomeBot.DataStore.ChannelStore
  alias HomeBot.DataStore.EnergyPostgresStore

  def add_subscriber(channel_id) do
    ChannelStore.add_subscriber(channel_id)
  end

  def get_subscribers do
    ChannelStore.get_subscribers()
  end

  def get_latest_energy_measurement do
    EnergyPostgresStore.get_latest_measurement()
  end

  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(map())
  def get_energy_usage(start_time, end_time, group_quantity, group_unit) do
    EnergyPostgresStore.get_energy_usage(start_time, end_time, group_quantity, group_unit)
  end

  def get_energy_usage(group_quantity, group_unit) do
    start_time = DateTime.from_unix!(0)
    end_time = DateTime.from_unix!(10_000_000_000)
    EnergyPostgresStore.get_energy_usage(start_time, end_time, group_quantity, group_unit)
  end

  def get_daily_energy_usage() do
    start_time = DateTime.from_unix!(0)
    end_time = DateTime.from_unix!(10_000_000_000)
    EnergyPostgresStore.get_daily_energy_usage(start_time, end_time)
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
