defmodule HomeWeather.Jobs do
  def get_hourly_weather_data do
    HomeWeather.OpenWeather.GetHourlyWeatherDataJob.run()
  end
end
