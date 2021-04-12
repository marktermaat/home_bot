defmodule HomeBot.Weather.OpenweatherTemperatureLogger do
  @moduledoc "The task that retrieves weather hourly data and stores it"

  @lat "52.2658"
  @long "6.7931"

  def run do
    retrieve_and_store_weather_data(Timex.shift(Timex.now(), days: -1))
    retrieve_and_store_weather_data(Timex.now())
  end

  def retrieve_and_store_weather_data(timestamp) do
    body = get_hourly_weather_data(DateTime.to_unix(timestamp))

    HomeBot.DataStore.create_temperature_database_if_not_exists()

    datapoints =
      Jason.decode!(body)
      |> Map.get("hourly", [])
      |> Enum.map(&process_hour_record/1)

    HomeBot.DataStore.write_temperature_data(datapoints)
  end

  defp get_hourly_weather_data(timestamp, retry \\ 3, _ \\ nil)
  defp get_hourly_weather_data(_, _retry = 0, error) do
    raise "Unexpected response from OpenWeather API: #{inspect(error)}"
  end

  defp get_hourly_weather_data(timestamp, retry, _) do
    HTTPoison.start()

    try do
      %HTTPoison.Response{status_code: 200, body: body} = HTTPoison.get!(
        "https://api.openweathermap.org/data/2.5/onecall/timemachine?lat=#{@lat}&lon=#{@long}&dt=#{
          timestamp
        }&appid=#{api_key()}&units=metric",
        recv_timeout: 30_000
      )

      body
    rescue
      e -> get_hourly_weather_data(timestamp, retry - 1, inspect(e))
    end
  end

  defp process_hour_record(record) do
    timestamp = DateTime.from_unix!(record["dt"])

    [
      timestamp: timestamp,
      temperature: record["temp"],
      humidity: record["humidity"],
      precipitation: get_in(record, ["rain", "1h"]) || 0,
      wind_direction: record["wind_deg"],
      wind_speed: record["wind_speed"]
    ]
  end

  defp api_key do
    Application.fetch_env!(:home_bot, :openweather_api_key)
  end
end
