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
    datapoints =
      data
      |> Enum.reject(fn r -> is_nil(r[:temperature]) end)
      |> Enum.map(&to_datapoint/1)
      |> Enum.to_list()

    :ok =
      InfluxConnection.write(%{
        points: datapoints,
        database: "energy"
      })
  end

  def get_average_temperature_per_day(:all) do
    InfluxConnection.get_list(
      "SELECT MEAN(temperature) as temperature FROM temperature GROUP BY time(1d)",
      "energy"
    )
    |> fix_timezone()
  end

  def get_average_temperature_per_day(days) do
    InfluxConnection.get_list(
      "SELECT MEAN(temperature) as temperature FROM temperature WHERE time >= now() -#{days}d GROUP BY time(1d)",
      "energy"
    )
    |> fix_timezone()
  end

  def get_average_temperature_per_day(start_time, end_time) do
    InfluxConnection.get_list(
      "SELECT MEAN(temperature) as temperature FROM temperature WHERE time >= '#{start_time}' AND time < '#{end_time}' GROUP BY time(1d)",
      "energy"
    )
    |> fix_timezone()
  end

  def get_average_temperature(start_time, end_time) do
    InfluxConnection.get_single(
      "SELECT MEAN(temperature) as temperature FROM temperature WHERE time >= '#{start_time}' AND time < '#{end_time}'",
      "energy"
    )
    |> Map.update("time", Timex.now(), &to_timezone/1)
  end

  defp to_datapoint(record) do
    %{
      database: "energy",
      measurement: "temperature",
      fields: %{
        # Dividing by 1 to cast integer to float
        temperature: record[:temperature] / 1,
        humidity: record[:humidity],
        precipitation: (record[:precipitation] || 0) / 1,
        wind_direction: record[:wind_direction],
        wind_speed: (record[:wind_speed] || 0) / 1
      },
      timestamp: DateTime.to_unix(record[:timestamp], :nanosecond)
    }
  end

  defp fix_timezone(records) do
    Enum.map(records, fn record ->
      Map.update!(record, "time", &to_timezone/1)
    end)
  end

  defp to_timezone(time) do
    {:ok, dt} = NaiveDateTime.from_iso8601(time)

    Timex.to_datetime(dt, "Europe/Amsterdam")
    |> Timex.to_datetime()
  end
end
