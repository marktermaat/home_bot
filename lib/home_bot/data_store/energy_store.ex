defmodule HomeBot.DataStore.EnergyStore do
  @moduledoc "The datastore of energy data"

  alias HomeBot.DataStore.InfluxConnection

  def get_latest_measurement do
    InfluxConnection.get_single(
      "SELECT * FROM smart_meter GROUP BY * ORDER BY DESC LIMIT 1 tz('Europe/Amsterdam')",
      "energy")
  end

  def get_measurements_since(datetime) do
    InfluxConnection.get_list(
      "SELECT * FROM smart_meter where time > '#{DateTime.to_iso8601(datetime)}' ORDER BY ASC tz('Europe/Amsterdam')",
      "energy")
  end

  def get_gas_usage(group, start_time, end_time) do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(current_gas_usage)) as usage FROM smart_meter WHERE time >= '#{start_time}' AND time < '#{end_time}' GROUP BY time(#{group}) tz('Europe/Amsterdam')",
      "energy")
  end

  def get_gas_usage_per_hour(days) do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(current_gas_usage)) as usage FROM smart_meter WHERE time >= now() -#{days}d GROUP BY time(1h) tz('Europe/Amsterdam')",
      "energy")
  end

  def get_gas_usage_per_day(:all) do
    gas_usage = InfluxConnection.get_list(
      "SELECT MAX(current_gas_usage) as usage FROM smart_meter GROUP BY time(1d) tz('Europe/Amsterdam')",
      "energy")

    {usage_differences, _} = Enum.map_reduce(gas_usage, :empty, fn record, acc ->
      case acc do
        :empty -> {nil, record["usage"]}
        previous -> {Map.put(record, "usage", record["usage"] - previous), record["usage"]}
      end
    end)

    Enum.reject(usage_differences, &is_nil/1)
  end

  def get_gas_usage_per_day(days) do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(current_gas_usage)) as usage FROM smart_meter WHERE time >= now() -#{days}d GROUP BY time(1d) tz('Europe/Amsterdam')",
      "energy")
  end

  def get_electricity_usage(group, start_time, end_time) do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(meter_low_tariff)) as low_tariff_usage, DIFFERENCE(MAX(meter_normal_tariff)) as normal_tariff_usage FROM smart_meter WHERE time >= '#{start_time}' AND time < '#{end_time}' GROUP BY time(#{group}) tz('Europe/Amsterdam')",
      "energy")
  end

  def get_electricity_usage_per_hour(days) do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(meter_total_tariff)) as usage FROM smart_meter WHERE time >= now() -#{days}d GROUP BY time(1h) tz('Europe/Amsterdam')",
      "energy")
  end

  def get_electricity_usage_per_day(days) do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(meter_low_tariff)) as low_tariff_usage, DIFFERENCE(MAX(meter_normal_tariff)) as normal_tariff_usage FROM smart_meter WHERE time >= now() -#{days}d GROUP BY time(1d) tz('Europe/Amsterdam')",
      "energy")
  end

  def get_electricity_usage(minutes) do
    InfluxConnection.get_list(
      "SELECT current_energy_usage as usage FROM smart_meter WHERE time >= now() -#{minutes}m tz('Europe/Amsterdam')",
      "energy")
  end
end
