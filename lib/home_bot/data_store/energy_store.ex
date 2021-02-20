defmodule HomeBot.DataStore.EnergyStore do
  @moduledoc "The datastore of energy data"

  alias HomeBot.DataStore.InfluxConnection

  def get_latest_measurement do
    InfluxConnection.get_single(
      "SELECT * FROM smart_meter GROUP BY * ORDER BY DESC LIMIT 1",
      "energy")
  end

  def get_gas_usage_per_hour(days) do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(current_gas_usage)) as usage FROM smart_meter WHERE time >= now() -#{days}d GROUP BY time(1h)",
      "energy")
  end

  def get_gas_usage_per_day(:all) do
    gas_usage = InfluxConnection.get_list(
      "SELECT MAX(current_gas_usage) as usage FROM smart_meter GROUP BY time(1d)",
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
      "SELECT DIFFERENCE(MAX(current_gas_usage)) as usage FROM smart_meter WHERE time >= now() -#{days}d GROUP BY time(1d)",
      "energy")
  end
end
