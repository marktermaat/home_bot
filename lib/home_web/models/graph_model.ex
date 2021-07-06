defmodule HomeWeb.Models.GraphModel do
  @moduledoc "This model constructs data for graphs"

  import HomeBot.Tools

  alias HomeBot.DataStore

  use Timex

  def gas_usage_data(group, start_time, end_time, title \\ "Gas usage") do
    result = DataStore.get_gas_usage(group, start_time, end_time)

    labels = result |> Enum.map(&(Map.fetch!(&1, "time")))
    values = result |> Enum.map(&(Map.fetch!(&1, "usage")))

    %{
      title: title,
      labels: labels,
      datasets: [%{
        name: "Gas",
        data: values
      }]
    }
  end

  def electricity_usage_data(group, start_time, end_time, title \\ "Electricity usage") do
    result = DataStore.get_electricity_usage(group, start_time, end_time)
    labels = get_labels(result)

    %{
      title: title,
      labels: labels,
      datasets: [
        %{
          name: "Low tariff (kWh)",
          data: Enum.map(result, &(Map.fetch!(&1, "low_tariff_usage")))
        },
        %{
          name: "Normal tariff (kWh)",
          data: Enum.map(result, &(Map.fetch!(&1, "normal_tariff_usage")))
        }
      ]
    }
  end


  def daily_gas_and_temperature_data do
    gas_usage = DataStore.get_gas_usage_per_day(48)
    temps = DataStore.get_average_temperature_per_day(48)

    labels = get_labels(gas_usage)

    gas_values = gas_usage |> Enum.map(&(Map.fetch!(&1, "usage")))
    temperature_values = temps |> Enum.map(&(Map.fetch!(&1, "temperature")))

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
    daily_temperatures = DataStore.get_average_temperature_per_day(:all)
    daily_gas_usage = DataStore.get_gas_usage_per_day(:all)

    raw_data = join_on_key(daily_temperatures, daily_gas_usage, "time")
      |> Enum.group_by(fn record -> round(record["temperature"]) end)
      |> Enum.map(fn {temperature, records} -> [temperature, mean_for_key(records, "usage")] end)
      |> Enum.sort_by(fn [temperature, _gas_usage] -> temperature end)

    %{
      title: "Gas usage per temperature",
      labels: Enum.map(raw_data, fn [temperature, _gas_usage] -> temperature end),
      datasets: [%{
        name: "Gas",
        data: Enum.map(raw_data, fn [_temperature, gas_usage] -> gas_usage end)
      }]
    }
  end

  def gas_usage_per_temperature_per_year_data do
    daily_temperatures = DataStore.get_average_temperature_per_day(:all)
    daily_gas_usage = DataStore.get_gas_usage_per_day(:all)

    {%{"temperature" => _min_temp}, %{"temperature" => max_temp}} = Enum
      .filtere(fn record -> record["temperature"] != nil)
      .min_max_by(daily_temperatures, fn record -> record["temperature"] end)

    temp_range = 0..round(max_temp) |> Enum.to_list()

    raw_data = join_on_key(daily_temperatures, daily_gas_usage, "time")
      |> Enum.group_by(fn record -> get_year(record["time"]) end)
      |> Enum.map(fn {year, records} -> [year, to_gas_usage_per_temp(records, temp_range)] end)

    dataset_data = raw_data
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

  def hourly_electricity_usage_data do
    result = DataStore.get_electricity_usage_per_hour(3)
    labels = result |> Enum.map(&(Map.fetch!(&1, "time")))

    %{
      title: "Hourly electricity usage",
      labels: labels,
      datasets: [
        %{
          name: "Electricity (kWh)",
          data: Enum.map(result, &(Map.fetch!(&1, "usage")))
        },
      ]
    }
  end

  def current_electricity_usage_data do
    result = DataStore.get_electricity_usage(5)
    labels = result |> Enum.map(&(Map.fetch!(&1, "time")))

    %{
      title: "Electricity usage",
      labels: labels,
      datasets: [
        %{
          name: "Electricity (kW)",
          data: Enum.map(result, &(Map.fetch!(&1, "usage")))
        },
      ]
    }
  end

  def get_gas_mean_and_sd_of_period(period_start, period_end, ticks_string) do
    data = DataStore.get_gas_usage("1h", period_start, period_end)
    get_mean_and_sd_of_period(data, ticks_string)
  end

  def get_electricity_mean_and_sd_of_period(period_start, period_end, ticks_string) do
    data = DataStore.get_electricity_usage("1h", period_start, period_end)
    |> Enum.map(fn record -> %{"time" => record["time"], "usage" => record["low_tariff_usage"] + record["normal_tariff_usage"]} end)
    get_mean_and_sd_of_period(data, ticks_string)
  end

  defp get_mean_and_sd_of_period(data, ticks_string) do
    ticks = String.split(ticks_string, ",")
    |> Enum.map(&String.to_integer/1)

    values = data
    |> Enum.filter(fn %{"time" => time} -> Enum.member?(ticks, get_hour(time)) end)
    |> Enum.map(fn %{"usage" => usage} -> usage end)

    mean = mean(values)
    sd = standard_deviation(values, mean)

    {mean, sd}
  end

  defp to_gas_usage_per_temp(records, temp_range) do
    grouped_records = records  |> Enum.group_by(fn record -> round(record["temperature"]) end)
    temp_range
      |> Enum.map(fn temperature -> [temperature, mean_for_key(Map.get(grouped_records, temperature, []), "usage")] end)
      |> Enum.sort_by(fn [temperature, _gas_usage] -> temperature end)
  end

  def get_hour(datetime) do
    {:ok, dt, _} = DateTime.from_iso8601(datetime)
    Timezone.convert(dt, "Europe/Amsterdam").hour
  end

  defp get_year(datetime) do
    {:ok, dt, _} = DateTime.from_iso8601(datetime)
    DateTime.to_date(dt).year
  end

  defp get_labels(records) do
    records
    |> Enum.map(&(Map.fetch!(&1, "time")))
    |> Enum.map(&DateTime.from_iso8601/1) # TODO: Time is in UTC, convert to Europe/Amsterdam
    |> Enum.map(fn {:ok, dt, _} -> DateTime.to_date(dt) end)
  end
end
