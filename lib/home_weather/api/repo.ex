defmodule HomeWeather.Api.Repo do
  alias HomeWeather.Api.WeatherRecord
  alias HomeWeather.Api.WeatherSummary

  @spec get_latest_weather_record() :: WeatherRecord.t()
  def get_latest_weather_record do
    query = "SELECT * FROM weather_hour_events order by time desc limit 1"

    %Postgrex.Result{columns: columns, rows: [row]} =
      Postgrex.query!(HomeBot.DbConnection, query, [], timeout: 10_000)

    result = Enum.zip(columns, row) |> Enum.into(%{})

    %WeatherRecord{
      timestamp: result["time"],
      humidity: result["humidity"],
      precipitation: result["precipitation"] |> Decimal.round(2) |> Decimal.to_float(),
      temperature: result["temperature"] |> Decimal.round(2) |> Decimal.to_float(),
      wind_direction: result["wind_direction"],
      wind_speed: result["wind_speed"] |> Decimal.round(2) |> Decimal.to_float()
    }
  end

  @spec get_average_temperature_during_day(
          DateTime.t() | NaiveDateTime.t(),
          DateTime.t() | NaiveDateTime.t(),
          integer(),
          atom()
        ) ::
          [WeatherSummary.t()]
  def get_average_temperature_during_day(
        start_time,
        end_time,
        aggregation_amount,
        aggregation_unit
      ) do
    query =
      "SELECT time_bucket('#{aggregation_amount} #{aggregation_unit}'::interval, time) AS bucket, AVG(temperature) FROM weather_hour_events WHERE time >= $1 AND time < $2 AND time::timestamp::time > '05:00:00' AND time::timestamp::time < '20:00:00' GROUP BY bucket ORDER BY bucket"

    %Postgrex.Result{columns: columns, rows: rows} =
      Postgrex.query!(HomeBot.DbConnection, query, [start_time, end_time], timeout: 10_000)

    result =
      rows
      |> Enum.map(fn row -> Enum.zip(columns, row) end)
      |> Enum.map(fn row -> Enum.into(row, %{}) end)
      |> Enum.map(fn record ->
        %WeatherSummary{day_timestamp: record["bucket"], temperature: record["avg"]}
      end)

    result
  end

  @spec get_average_temperature(
          DateTime.t() | NaiveDateTime.t(),
          DateTime.t() | NaiveDateTime.t()
        ) :: Decimal.t()
  def get_average_temperature(start_time, end_time) do
    query = "SELECT avg(temperature) FROM weather_hour_events where time >= $1 AND time < $2"

    %Postgrex.Result{rows: [average_temperature]} =
      Postgrex.query!(HomeBot.DbConnection, query, [start_time, end_time], timeout: 10_000)

    average_temperature |> List.first()
  end
end
