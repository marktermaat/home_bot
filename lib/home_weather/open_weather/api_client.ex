defmodule HomeWeather.OpenWeather.ApiClient do
  @moduledoc "The API client for OpenWeather"
  use Retry

  alias HomeWeather.OpenWeather.WeatherValue

  @lat "52.2658"
  @long "6.7931"

  @spec get_hourly_weather_data(Date.t()) :: [WeatherValue.t()]
  def get_hourly_weather_data(date) do
    unix_date = DateTime.new!(date, ~T[00:00:00]) |> DateTime.to_unix()
    HTTPoison.start()

    {:ok, %HTTPoison.Response{status_code: 200, body: body}} =
      retry with: constant_backoff(1000) |> Stream.take(10) do
        HTTPoison.get(
          "https://api.openweathermap.org/data/3.0/onecall/timemachine?lat=#{@lat}&lon=#{@long}&dt=#{unix_date}&appid=#{api_key()}&units=metric",
          recv_timeout: 30_000
        )
      after
        result -> result
      else
        error -> raise "Unexpected response from OpenWeather API: #{inspect(error)}"
      end

    body
    |> Jason.decode!(keys: :atoms)
    |> Map.get(:hourly, [])
    |> Enum.map(&to_energy_value/1)
  end

  defp to_energy_value(record) do
    %WeatherValue{
      timestamp: DateTime.from_unix!(record[:dt]) |> DateTime.to_naive(),
      humidity: record[:humidity],
      precipitation: get_in(record, [:rain, :"1h"]) || 0,
      temperature: record[:temp],
      wind_direction: record[:wind_deg],
      wind_speed: record[:wind_speed]
    }
  end

  defp api_key do
    Application.fetch_env!(:home_bot, :openweather_api_key)
  end
end
