defmodule HomeWeather.OpenWeather.MqttPublisher do
  alias HomeWeather.OpenWeather.WeatherValue

  @spec publish_hourly_weather_data([WeatherValue.t()]) :: :ok
  def publish_hourly_weather_data(records) do
    records
    |> Enum.map(&Jason.encode!/1)
    |> Enum.each(fn message ->
      Tortoise.publish(client_id(), "data/weather/hour_summary", message, qos: 1)
    end)
  end

  def client_id, do: Application.fetch_env!(:home_bot, :mqtt_client_id)
end
