defmodule HomeWeather.OpenWeather.GetHourlyWeatherDataJob do
  alias HomeWeather.OpenWeather.ApiClient
  alias HomeWeather.OpenWeather.MqttPublisher

  def run() do
    today = Date.utc_today()
    yesterday = Date.add(today, -1)

    ApiClient.get_hourly_weather_data(yesterday)
    |> then(&MqttPublisher.publish_hourly_weather_data/1)

    ApiClient.get_hourly_weather_data(today)
    |> then(&MqttPublisher.publish_hourly_weather_data/1)
  end
end
