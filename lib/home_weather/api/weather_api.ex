defmodule HomeWeather.Api.WeatherApi do
  alias HomeWeather.Api.Repo
  alias HomeWeather.Api.WeatherSummary

  def get_latest_weather_record do
    Repo.get_latest_weather_record()
  end

  @spec get_average_temperature_per_day_during_daylight(integer()) :: [WeatherSummary.t()]
  def get_average_temperature_per_day_during_daylight(days) do
    end_time = Date.utc_today() |> DateTime.new!(~T[00:00:00])
    start_time = Date.add(Date.utc_today(), -days) |> DateTime.new!(~T[00:00:00])

    Repo.get_average_temperature_during_day(start_time, end_time, 1, :day)
  end

  @spec get_average_temperature_per_day_during_daylight(
          DateTime.t() | NaiveDateTime.t(),
          DateTime.t() | NaiveDateTime.t()
        ) :: [WeatherSummary.t()]
  def get_average_temperature_per_day_during_daylight(start_time, end_time) do
    Repo.get_average_temperature_during_day(start_time, end_time, 1, :day)
  end

  def get_average_temperature_per_day() do
    end_time = Date.utc_today() |> DateTime.new!(~T[00:00:00])
    start_time = Date.add(Date.utc_today(), -10_000) |> DateTime.new!(~T[00:00:00])

    Repo.get_average_temperature_during_day(start_time, end_time, 1, :day)
  end

  @spec get_average_temperature(
          DateTime.t() | NaiveDateTime.t(),
          DateTime.t() | NaiveDateTime.t()
        ) :: Decimal.t()
  def get_average_temperature(start_time, end_time) do
    Repo.get_average_temperature(start_time, end_time)
  end
end
