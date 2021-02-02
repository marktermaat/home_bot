defmodule HomeBot.DataStore.TemperatureStore do
  def create_database_if_not_exists() do
    HomeBot.DataStore.InfluxConnection.query(
      "CREATE DATABASE energy",
      method: :post
    )
  end

  def write_temperature_data(data) do
    datapoints = data
      |> Enum.reject(fn r -> is_nil(r[:temperature]) end)
      |> Enum.map(&to_datapoint/1)
      |> Enum.to_list()

    :ok = HomeBot.DataStore.InfluxConnection.write(%{
      points: datapoints,
      database: "energy"
    })
  end

  def get_latest_temperature() do
    %{results: results} = HomeBot.DataStore.InfluxConnection.query(
      "SELECT * FROM temperature GROUP BY * ORDER BY DESC LIMIT 1",
      database: "energy"
    )

    %{series: [result]} = List.first(results)
    zipped = Enum.zip(result.columns, List.first(result.values))
    Enum.into(zipped, %{})
  end

  defp to_datapoint(record) do
    %{
      database: "energy",
      measurement: "temperature",
      fields: %{temperature: record[:temperature] / 1}, # Dividing by 1 to cast integer to float
      timestamp: DateTime.to_unix(record[:timestamp], :nanosecond)
    }
  end
end
