defmodule HomeBot.DataStore.TemperatureStore do
  @moduledoc "The datastore for weather data"

  alias HomeBot.DataStore.InfluxConnection

  def create_database_if_not_exists do
    InfluxConnection.query(
      "CREATE DATABASE energy",
      method: :post
    )
  end

  def write_temperature_data(data) do
    datapoints = data
      |> Enum.reject(fn r -> is_nil(r[:temperature]) end)
      |> Enum.map(&to_datapoint/1)
      |> Enum.to_list()

    :ok = InfluxConnection.write(%{
      points: datapoints,
      database: "energy"
    })
  end

  def get_latest_weather_data do
    %{results: results} = InfluxConnection.query(
      "SELECT * FROM temperature GROUP BY * ORDER BY DESC LIMIT 1",
      database: "energy"
    )

    %{series: [result]} = List.first(results)
    zipped = Enum.zip(result.columns, List.first(result.values))
    Enum.into(zipped, %{})
  end

  def get_average_temperature_per_day do
    InfluxConnection.get_list(
      "SELECT MEAN(temperature) as temperature FROM temperature WHERE time >= now() -28d GROUP BY time(1d)",
      "energy")
  end

  defp to_datapoint(record) do
    %{
      database: "energy",
      measurement: "temperature",
      fields: %{
        temperature: record[:temperature] / 1, # Dividing by 1 to cast integer to float
        humidity: record[:humidity],
        precipitation: (record[:precipitation] || 0) / 1,
        wind_direction: record[:wind_direction],
        wind_speed: record[:wind_speed] / 1
      },
      timestamp: DateTime.to_unix(record[:timestamp], :nanosecond)
    }
  end
end
