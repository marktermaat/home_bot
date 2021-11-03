defmodule HomeBot.DataStore.HomeClimateStore do
  @moduledoc "Data store for Home Climate data"

  import HomeBot.DataStore.PostgresStore

  def get_latest_temperature do
    result =
      Postgrex.query!(
        HomeBot.DbConnection,
        "SELECT * FROM home_climate_events ORDER BY time DESC limit 1",
        []
      )

    result_to_map(result)
    |> List.first()
    |> Keyword.get(:temperature, 0)
  end

  def get_latest_humidity do
    result =
      Postgrex.query!(
        HomeBot.DbConnection,
        "SELECT * FROM home_climate_events ORDER BY time DESC limit 1",
        []
      )

    result_to_map(result)
    |> List.first()
    |> Keyword.get(:humidity, 0)
  end

  def get_recent_home_climate_data(hours \\ 24) do
    result =
      Postgrex.query!(
        HomeBot.DbConnection,
        "SELECT * FROM home_climate_events WHERE time > (NOW() - interval '#{hours} hours') ORDER BY time DESC",
        []
      )

    result_to_map(result)
  end
end
