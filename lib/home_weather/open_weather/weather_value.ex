defmodule HomeWeather.OpenWeather.WeatherValue do
  @enforce_keys [
    :timestamp,
    :humidity,
    :precipitation,
    :temperature,
    :wind_direction,
    :wind_speed
  ]
  @derive Jason.Encoder
  defstruct [:timestamp, :humidity, :precipitation, :temperature, :wind_direction, :wind_speed]

  @type t :: %HomeWeather.OpenWeather.WeatherValue{
          timestamp: NaiveDateTime.t(),
          humidity: integer(),
          precipitation: float(),
          temperature: float(),
          wind_direction: integer(),
          wind_speed: float()
        }
end
