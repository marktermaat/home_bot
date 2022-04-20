defmodule HomeWeather.Api.WeatherApi do
  alias HomeWeather.Api.Repo

  def get_latest_weather_record do
    Repo.get_latest_weather_record()
  end

  def get_average_temperature_per_day_during_daylight(days \\ 10_000) do
    end_time = Date.utc_today() |> DateTime.new(~T[00:00:00])
    start_time = Date.add(Date.utc_today(), -days) |> DateTime.new(~T[00:00:00])

    Repo.get_average_temperature_during_day(start_time, end_time, 1, :day)
  end
end
