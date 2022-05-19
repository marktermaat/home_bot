defmodule HomeEnergy.Repo.EnergyRepo do
  @moduledoc "Energy Repo"

  import HomeBot.DataStore.PostgresStore

  alias HomeEnergy.Model.EnergyPeriod

  @spec get_energy_usage(NaiveDateTime.t(), NaiveDateTime.t(), integer(), String.t()) ::
          list(EnergyPeriod.t())
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

    result = long_running_query(query, [start_time, end_time])
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

  def get_energy_increase(previous, current) do
    %EnergyPeriod{
      start_time: current[:bucket] || current[:day],
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
      usage_gas: sub(current[:max_gas_meter], previous[:max_gas_meter])
    }
  end

  defp sub(nil, _), do: 0
  defp sub(_, nil), do: 0

  defp sub(current, previous) do
    Decimal.sub(current, previous)
    |> Decimal.to_float()
  end
end
