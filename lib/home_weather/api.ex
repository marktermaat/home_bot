defmodule HomeWeather.Api do
  alias HomeWeather.Api.WeatherApi
  alias HomeWeather.Api.WeatherRecord

  @spec get_latest_weather_record() :: WeatherRecord.t()
  def get_latest_weather_record do
    WeatherApi.get_latest_weather_record()
  end
end
