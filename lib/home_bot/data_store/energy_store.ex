defmodule HomeBot.DataStore.EnergyStore do
  @moduledoc "The datastore of energy data"

  alias HomeBot.DataStore.InfluxConnection

  def get_latest_measurement do
    InfluxConnection.get_single(
      "SELECT * FROM smart_meter GROUP BY * ORDER BY DESC LIMIT 1",
      "energy")
  end

  def get_gas_usage_per_hour do
    InfluxConnection.get_list(
      "SELECT DIFFERENCE(MAX(current_gas_usage)) as usage FROM smart_meter WHERE time >= now() -3d GROUP BY time(1h)",
      "energy")
  end
end
