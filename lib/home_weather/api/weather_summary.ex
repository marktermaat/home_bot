defmodule HomeWeather.Api.WeatherSummary do
  defstruct [:day_timestamp, :temperature]

  @type t :: %HomeWeather.Api.WeatherSummary{
          day_timestamp: NaiveDateTime.t(),
          temperature: Decimal.t()
        }

  def temperature_as_int(summary) do
    summary.temperature |> Decimal.round() |> Decimal.to_integer()
  end
end
