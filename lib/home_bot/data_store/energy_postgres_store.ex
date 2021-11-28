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
  def get_energy_usage(start_time, end_time, group_unit, group_quantity) do
    query = """
    SELECT time_bucket('#{group_unit} #{group_quantity}'::interval, time) AS bucket, 
      MIN(meter_low_tariff) AS min_meter_low_tariff, 
      MAX(meter_low_tariff) AS meter_low_tariff, 
      MIN(meter_normal_tariff) AS min_meter_normal_tariff, 
      MAX(meter_normal_tariff) AS meter_normal_tariff, 
      MIN(meter_supplied_low_tariff) AS min_meter_supplied_low_tariff, 
      MAX(meter_supplied_low_tariff) AS meter_supplied_low_tariff, 
      MIN(meter_supplied_normal_tariff) AS min_meter_supplied_normal_tariff, 
      MAX(meter_supplied_normal_tariff) AS meter_supplied_normal_tariff, 
      MIN(meter_total_tariff) AS min_meter_total_tariff, 
      MAX(meter_total_tariff) AS meter_total_tariff, 
      MIN(meter_supplied_total_tariff) AS min_meter_supplied_total_tariff,
      MAX(meter_supplied_total_tariff) AS meter_supplied_total_tariff,
      MIN(current_gas_usage) AS min_gas_meter,
      MAX(current_gas_usage) as gas_meter
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
        {get_electricity_increase(previous, elem), elem}
      end)

    result
  end

  def get_electricity_increase(previous, current) do
    %{
      time: current[:bucket],
      usage_low_tariff:
        Decimal.sub(
          current[:meter_low_tariff],
          previous[:meter_low_tariff]
        )
        |> Decimal.to_float(),
      usage_normal_tariff:
        Decimal.sub(
          current[:meter_normal_tariff],
          previous[:meter_normal_tariff]
        )
        |> Decimal.to_float(),
      supplied_low_tariff:
        Decimal.sub(
          current[:meter_supplied_low_tariff],
          previous[:meter_supplied_low_tariff]
        )
        |> Decimal.to_float(),
      supplied_normal_tariff:
        Decimal.sub(
          current[:meter_supplied_normal_tariff],
          previous[:meter_supplied_normal_tariff]
        )
        |> Decimal.to_float(),
      supplied_total_tariff:
        Decimal.sub(
          current[:meter_supplied_total_tariff],
          previous[:meter_supplied_total_tariff]
        )
        |> Decimal.to_float(),
      usage_total_tariff:
        Decimal.sub(
          current[:meter_total_tariff],
          previous[:meter_total_tariff]
        )
        |> Decimal.to_float(),
      usage_gas_meter:
        Decimal.sub(
          current[:gas_meter],
          previous[:gas_meter]
        )
        |> Decimal.to_float()
    }
  end
end
