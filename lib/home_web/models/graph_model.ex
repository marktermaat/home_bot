defmodule HomeWeb.Models.GraphModel do
  @moduledoc "This model constructs data for graphs"

  import HomeBot.Tools

  alias HomeBot.DataStore
  alias HomeEnergy.Api
  alias HomeWeather.Api, as: WeatherApi
  alias HomeWeather.Api.WeatherSummary

  use Timex

  def gas_usage_data(start_time, end_time, group_quantity, group_unit, title \\ "Gas usage") do
    result = DataStore.get_energy_usage(start_time, end_time, group_quantity, group_unit)

    labels = result |> Enum.map(&Map.fetch!(&1, :time))
    values = result |> Enum.map(&Map.fetch!(&1, :usage_gas_meter))

    %{
      title: title,
      labels: labels,
      datasets: [
        %{
          name: "Gas",
          data: values
        }
      ]
    }
  end

  def electricity_usage_data(
        start_time,
        end_time,
        group_unit,
        group_quantity,
        title \\ "Electricity usage"
      ) do
    result = DataStore.get_energy_usage(start_time, end_time, group_unit, group_quantity)
    labels = get_labels(result)

    %{
      title: title,
      labels: labels,
      datasets: [
        %{
          name: "Low tariff (kWh)",
          data: Enum.map(result, &Map.fetch!(&1, :usage_low_tariff))
        },
        %{
          name: "Normal tariff (kWh)",
          data: Enum.map(result, &Map.fetch!(&1, :usage_normal_tariff))
        }
      ]
    }
  end

  def daily_gas_and_temperature_data(start_time, end_time) do
    gas_usage = DataStore.get_energy_usage(start_time, end_time, 1, "day")

    temperatures = WeatherApi.get_average_temperature_per_day(start_time, end_time)

    labels = get_labels(gas_usage)

    gas_values = gas_usage |> Enum.map(&Map.fetch!(&1, :usage_gas_meter))
    temperature_values = temperatures |> Enum.map(fn record -> record.temperature end)

    %{
      title: "Daily gas usage",
      labels: labels,
      datasets: [
        %{
          name: "Gas (m3)",
          data: gas_values
        },
        %{
          name: "Temperature (°C)",
          data: temperature_values
        }
      ]
    }
  end

  def gas_usage_per_temperature_data do
    daily_temperatures = WeatherApi.get_average_temperature_per_day()
    daily_gas_usage = DataStore.get_daily_energy_usage()

    raw_data =
      daily_temperatures
      |> Enum.map(&Map.from_struct/1)
      |> join_on_key(daily_gas_usage, :day_timestamp, :time)
      |> Enum.filter(fn record -> record[:temperature] != nil end)
      |> Enum.group_by(&WeatherSummary.temperature_as_int/1)
      |> Enum.map(fn {temperature, records} ->
        [temperature, mean_for_key(records, :usage_gas_meter)]
      end)
      |> Enum.sort_by(fn [temperature, _gas_usage] -> temperature end)

    %{
      title: "Gas usage per temperature",
      labels: Enum.map(raw_data, fn [temperature, _gas_usage] -> temperature end),
      datasets: [
        %{
          name: "Gas",
          data: Enum.map(raw_data, fn [_temperature, gas_usage] -> gas_usage end)
        }
      ]
    }
  end

  def gas_usage_per_temperature_per_year_data do
    daily_temperatures = WeatherApi.get_average_temperature_per_day()
    daily_gas_usage = DataStore.get_daily_energy_usage()

    {_min_summary, max_summary} =
      daily_temperatures
      |> Enum.filter(fn record -> record.temperature != nil end)
      |> Enum.min_max_by(fn record -> record.temperature end)

    max_temp = WeatherSummary.temperature_as_int(max_summary)
    temp_range = 0..round(max_temp) |> Enum.to_list()

    raw_data =
      daily_temperatures
      |> Enum.map(&Map.from_struct/1)
      |> join_on_key(daily_gas_usage, :day_timestamp, :time)
      |> Enum.group_by(fn record -> get_year(record[:time]) end)
      |> Enum.map(fn {year, records} -> [year, to_gas_usage_per_temp(records, temp_range)] end)

    dataset_data =
      raw_data
      |> Enum.map(fn [year, records] ->
        %{
          name: year,
          data: Enum.map(records, fn [_temperature, gas_usage] -> gas_usage end)
        }
      end)

    %{
      title: "Gas usage per temperature per year",
      labels: temp_range,
      datasets: dataset_data
    }
  end

  def current_electricity_usage_data do
    result = DataStore.get_electricity_usage(5)
    labels = result |> Enum.map(&Map.fetch!(&1, :time))

    %{
      title: "Electricity usage",
      labels: labels,
      datasets: [
        %{
          name: "Electricity (kW)",
          data: Enum.map(result, &Map.fetch!(&1, :usage))
        }
      ]
    }
  end

  def get_gas_mean_and_sd_of_period(period_start, period_end, ticks_string) do
    data = Api.get_energy_usage(period_start, period_end, 1, "hour")
    get_mean_and_sd_of_period(data, ticks_string, :usage_gas)
  end

  def get_electricity_mean_and_sd_of_period(period_start, period_end, ticks_string) do
    data = Api.get_energy_usage(period_start, period_end, 1, "hour")
    get_mean_and_sd_of_period(data, ticks_string, :usage_total_tariff)
  end

  defp get_mean_and_sd_of_period(data, ticks_string, field) do
    ticks =
      String.split(ticks_string, ",")
      |> Enum.map(&String.to_integer/1)

    values =
      data
      |> Enum.filter(fn period -> Enum.member?(ticks, get_hour(period.start_time)) end)
      |> Enum.map(fn period -> Map.get(period, field) end)

    mean = mean(values)
    sd = standard_deviation(values, mean)

    {mean, sd}
  end

  defp to_gas_usage_per_temp(records, temp_range) do
    grouped_records =
      records
      |> Enum.filter(fn record -> record["temperature"] != nil end)
      |> Enum.group_by(fn record -> round(record["temperature"]) end)

    temp_range
    |> Enum.map(fn temperature ->
      [temperature, mean_for_key(Map.get(grouped_records, temperature, []), :usage_gas_meter)]
    end)
    |> Enum.sort_by(fn [temperature, _gas_usage] -> temperature end)
  end

  def get_hour(datetime) do
    {:ok, dt, _} = DateTime.from_iso8601(datetime)
    Timezone.convert(dt, "Europe/Amsterdam").hour
  end

  defp get_year(datetime) do
    NaiveDateTime.to_date(datetime).year
  end

  defp get_labels(records) do
    records
    |> Enum.map(&Map.fetch!(&1, :time))

    # TODO: Time is in UTC, convert to Europe/Amsterdam
  end
end
