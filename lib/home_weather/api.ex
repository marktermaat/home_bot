defmodule HomeWeather.Api do
  alias HomeWeather.Api.WeatherApi
  alias HomeWeather.Api.WeatherRecord
  alias HomeWeather.Api.WeatherSummary

  @spec get_latest_weather_record() :: WeatherRecord.t()
  def get_latest_weather_record do
    WeatherApi.get_latest_weather_record()
  end

  @spec get_average_temperature_per_day(integer()) :: [WeatherSummary.t()]
  def get_average_temperature_per_day(days \\ 10_000) do
    WeatherApi.get_average_temperature_per_day_during_daylight(days)
  end

  @spec get_average_temperature_per_day(
          DateTime.t() | NaiveDateTime.t(),
          DateTime.t() | NaiveDateTime.t()
        ) :: [WeatherSummary.t()]
  def get_average_temperature_per_day(start_time, end_time) do
    WeatherApi.get_average_temperature_per_day_during_daylight(start_time, end_time)
  end

  @spec get_average_temperature(
          DateTime.t() | NaiveDateTime.t(),
          DateTime.t() | NaiveDateTime.t()
        ) :: Decimal.t()
  def get_average_temperature(start_time, end_time) do
    WeatherApi.get_average_temperature(start_time, end_time)
  end
end
