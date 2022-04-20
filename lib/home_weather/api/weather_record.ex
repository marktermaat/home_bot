defmodule HomeWeather.Api.WeatherRecord do
  defstruct [:timestamp, :humidity, :precipitation, :temperature, :wind_direction, :wind_speed]

  @type t :: %HomeWeather.Api.WeatherRecord{
          timestamp: NaiveDateTime.t(),
          humidity: integer(),
          precipitation: float(),
          temperature: float(),
          wind_direction: integer(),
          wind_speed: float()
        }
end
