defmodule HomeBot.DataStore.EnergyPostgresStore do
  @moduledoc "Data store for energy data"

  import HomeBot.DataStore.PostgresStore

  def get_latest_measurement do
    query("SELECT * FROM energy ORDER BY time DESC limit 1")
    |> List.first()
  end

  def get_measurements_since(datetime) do
    query("SELECT * FROM energy WHERE time > $1 ORDER BY time ASC", [datetime])
  end

  def get_electricity_usage(minutes) do
    query(
      "SELECT time, current_energy_usage as usage FROM energy WHERE time >= (NOW() - interval '#{minutes} minutes')"
    )
  end

  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(map())
  def get_energy_usage(start_time, end_time, group_quantity, group_unit) do
    query = """
    SELECT time_bucket('#{group_quantity} #{group_unit}'::interval, time) AS bucket, 
      MIN(meter_low_tariff) AS min_meter_low_tariff, 
      MAX(meter_low_tariff) AS max_meter_low_tariff, 
      MIN(meter_normal_tariff) AS min_meter_normal_tariff, 
      MAX(meter_normal_tariff) AS max_meter_normal_tariff, 
      MIN(meter_supplied_low_tariff) AS min_meter_supplied_low_tariff, 
      MAX(meter_supplied_low_tariff) AS max_meter_supplied_low_tariff, 
      MIN(meter_supplied_normal_tariff) AS min_meter_supplied_normal_tariff, 
      MAX(meter_supplied_normal_tariff) AS max_meter_supplied_normal_tariff, 
      MIN(meter_total_tariff) AS min_meter_total_tariff, 
      MAX(meter_total_tariff) AS max_meter_total_tariff, 
      MIN(meter_supplied_total_tariff) AS min_meter_supplied_total_tariff,
      MAX(meter_supplied_total_tariff) AS max_meter_supplied_total_tariff,
      MIN(current_gas_usage) AS min_gas_meter,
      MAX(current_gas_usage) as max_gas_meter
    FROM energy
    WHERE time >= $1 AND time < $2
    GROUP BY bucket
    ORDER BY bucket;
    """

    result = query(query, [start_time, end_time])
    first = List.first(result)

    start_values = %{
      meter_low_tariff: first[:min_meter_low_tariff],
      meter_normal_tariff: first[:min_meter_normal_tariff],
      meter_supplied_low_tariff: first[:min_meter_supplied_low_tariff],
      meter_supplied_normal_tariff: first[:min_meter_supplied_normal_tariff],
      meter_total_tariff: first[:min_meter_total_tariff],
      meter_supplied_total_tariff: first[:min_meter_supplied_total_tariff],
      gas_meter: first[:min_gas_meter]
    }

    {result, _} =
      Enum.map_reduce(result, start_values, fn elem, previous ->
        {get_energy_increase(previous, elem), elem}
      end)

    result
  end

  def get_daily_energy_usage(start_time, end_time) do
    query = """
    SELECT *
    FROM energy_day_summaries
    WHERE day >= $1 AND day < $2
    ORDER BY day;
    """

    result = query(query, [start_time, end_time])
    first = List.first(result)

    start_values = %{
      max_meter_low_tariff: first[:min_meter_low_tariff],
      max_meter_normal_tariff: first[:min_meter_normal_tariff],
      max_meter_supplied_low_tariff: first[:min_meter_supplied_low_tariff],
      max_meter_supplied_normal_tariff: first[:min_meter_supplied_normal_tariff],
      max_meter_total_tariff: first[:min_meter_total_tariff],
      max_meter_supplied_total_tariff: first[:min_meter_supplied_total_tariff],
      max_gas_meter: first[:min_gas_meter]
    }

    {result, _} =
      Enum.map_reduce(result, start_values, fn elem, previous ->
        {get_energy_increase(previous, elem), elem}
      end)

    result
  end

  def get_energy_increase(previous, current) do
    %{
      time: current[:bucket] || current[:day],
      usage_low_tariff: sub(current[:max_meter_low_tariff], previous[:max_meter_low_tariff]),
      usage_normal_tariff:
        sub(current[:max_meter_normal_tariff], previous[:max_meter_normal_tariff]),
      supplied_low_tariff:
        sub(current[:max_meter_supplied_low_tariff], previous[:max_meter_supplied_low_tariff]),
      supplied_normal_tariff:
        sub(
          current[:max_meter_supplied_normal_tariff],
          previous[:max_meter_supplied_normal_tariff]
        ),
      supplied_total_tariff:
        sub(current[:max_meter_supplied_total_tariff], previous[:max_meter_supplied_total_tariff]),
      usage_total_tariff:
        sub(current[:max_meter_total_tariff], previous[:max_meter_total_tariff]),
      usage_gas_meter: sub(current[:max_gas_meter], previous[:max_gas_meter])
    }
  end

  defp sub(nil, _), do: 0
  defp sub(_, nil), do: 0

  defp sub(current, previous) do
    Decimal.sub(current, previous)
    |> Decimal.to_float()
  end
end
