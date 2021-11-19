defmodule HomeBot.DataStore.EnergyPostgresStore do
  @moduledoc "Data store for energy data"

  import HomeBot.DataStore.PostgresStore

  def get_latest_measurement do
    result =
      Postgrex.query!(
        HomeBot.DbConnection,
        "SELECT * FROM energy ORDER BY time DESC limit 1",
        []
      )

    result_to_map(result)
    |> List.first()
  end
end
