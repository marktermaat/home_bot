defmodule HomeBot.Weather.TemperatureLogger do
  @station_id "06290"

  def run() do
    body = get_hourly_meteo_data()

    HomeBot.DataStore.create_temperature_database_if_not_exists()

    datapoints = Jason.decode!(body)
      |> Map.get("data")
      |> Enum.map(&process_hour_record/1)

    HomeBot.DataStore.write_temperature_data(datapoints)
  end

  defp get_hourly_meteo_data() do
    yesterday = Date.utc_today() |> Date.add(-1) |> Date.to_iso8601
    today = Date.utc_today() |> Date.to_iso8601

    HTTPoison.start()
    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!(
        "https://api.meteostat.net/v2/stations/hourly?station=#{@station_id}&start=#{yesterday}&end=#{today}&tz=Europe/Amsterdam",
        ["x-api-key": meteostats_api_key()]
      )

    body
  end

  defp meteostats_api_key() do
    Application.fetch_env!(:home_bot, :meteostat_api_key)
  end

  defp process_hour_record(record) do
    [date, time] = String.split(record["time_local"], " ")
    {:ok, timestamp} = DateTime.new(Date.from_iso8601!(date), Time.from_iso8601!(time))
    [timestamp: timestamp, temperature: record["temp"]]
  end
end
