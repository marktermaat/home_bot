defmodule HomeWeather.Api.WeatherSummary do
  defstruct [:day_timestamp, :temperature]

  @type t :: %HomeWeather.Api.WeatherSummary{
          day_timestamp: NaiveDateTime.t(),
          temperature: float()
        }
end
