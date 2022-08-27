defmodule HomeSolar.Api.Repo do
  import HomeBot.DataStore.PostgresStore

  alias HomeSolar.Model.SolarPeriod

  @spec get_power_produced(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(SolarPeriod.t())
  def get_power_produced(start_time, end_time, group_quantity, group_unit) do
    query = """
    SELECT time_bucket('#{group_quantity} #{group_unit}'::interval, time) AS bucket,
      sum(value) as produced
    FROM solar_quarter_energy
    WHERE time >= $1 and time < $2
    GROUP BY bucket
    ORDER BY bucket;
    """

    query(query, [start_time, end_time])
    |> Enum.map(fn record ->
      %SolarPeriod{
        timestamp: record[:bucket],
        power_produced: record[:produced] |> Decimal.round() |> Decimal.to_integer()
      }
    end)
  end

  @spec get_latest_record() :: SolarPeriod.t()
  def get_latest_record() do
    query = """
    SELECT *
    FROM solar_quarter_energy
    ORDER BY time DESC
    LIMIT 1
    """

    query(query, [])
    |> Enum.map(fn record ->
      %SolarPeriod{
        timestamp: record[:time],
        power_produced: record[:value] |> Decimal.round() |> Decimal.to_integer()
      }
    end)
    |> List.first()
  end
end
