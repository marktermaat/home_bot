defmodule HomeBot.DataStore.EnergyStore do
  def get_latest_measurement() do
    HomeBot.DataStore.InfluxConnection.get_query(
      "SELECT * FROM smart_meter GROUP BY * ORDER BY DESC LIMIT 1",
      "energy")
  end
end
