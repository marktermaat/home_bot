defmodule HomeWeb.EnergyController do
  use HomeWeb, :controller

  import HomeBot.Tools

  def hourly_gas_usage(conn, _params) do
    result = HomeBot.DataStore.get_gas_usage_per_hour(3)
    labels = result |> Enum.map(&(Map.fetch!(&1, "time")))
    values = result |> Enum.map(&(Map.fetch!(&1, "usage")))

    data = %{
      title: "Hourly gas usage",
      labels: labels,
      datasets: [%{
        name: "Gas",
        data: values
      }]
    }

    json(conn, data)
  end

  def daily_gas_usage(conn, _params) do
    result = HomeBot.DataStore.get_gas_usage_per_day(48)
    labels = result
    |> Enum.map(&(Map.fetch!(&1, "time")))
    |> Enum.map(&DateTime.from_iso8601/1) # TODO: Time is in UTC, convert to Europe/Amsterdam
    |> Enum.map(fn {:ok, dt, _} -> DateTime.to_date(dt) end)

    values = result |> Enum.map(&(Map.fetch!(&1, "usage")))

    data = %{
      title: "Daily gas usage",
      labels: labels,
      datasets: [%{
        name: "Gas",
        data: values
      }]
    }

    json(conn, data)
  end

  def daily_gas_and_temp(conn, _params) do
    gas_usage = HomeBot.DataStore.get_gas_usage_per_day(48)
    temps = HomeBot.DataStore.get_average_temperature_per_day(48)

    labels = gas_usage
    |> Enum.map(&(Map.fetch!(&1, "time")))
    |> Enum.map(&DateTime.from_iso8601/1) # TODO: Time is in UTC, convert to Europe/Amsterdam
    |> Enum.map(fn {:ok, dt, _} -> DateTime.to_date(dt) end)

    gas_values = gas_usage |> Enum.map(&(Map.fetch!(&1, "usage")))
    temperature_values = temps |> Enum.map(&(Map.fetch!(&1, "temperature")))

    data = %{
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

    json(conn, data)
  end

  def gas_usage_per_temperature(conn, _params) do
    daily_temperatures = HomeBot.DataStore.get_average_temperature_per_day(:all)
    daily_gas_usage = HomeBot.DataStore.get_gas_usage_per_day(:all)

    raw_data = join_on_key(daily_temperatures, daily_gas_usage, "time")
      |> Enum.group_by(fn record -> round(record["temperature"]) end)
      |> Enum.map(fn {temperature, records} -> [temperature, mean_for_key(records, "usage")] end)
      |> Enum.sort_by(fn [temperature, _gas_usage] -> temperature end)

    data = %{
      title: "Gas usage per temperature",
      labels: Enum.map(raw_data, fn [temperature, _gas_usage] -> temperature end),
      datasets: [%{
        name: "Gas",
        data: Enum.map(raw_data, fn [_temperature, gas_usage] -> gas_usage end)
      }]
    }

    json(conn, data)
  end

  def example_data(conn, _params) do
    data = %{
      title: "Test",
      labels: [1, 2, 3, 4, 5],
      datasets: [
        %{
          name: "Hourly gas usage",
          data: [1, 3, 5, 3, 1]
        },
        %{
          name: "Hourly energy usage",
          data: [5, 4, 3, 2, 1]
        },
        %{
          name: "Hourly energy usage",
          data: [1, 2, 3, 4, 5]
        },
        %{
          name: "Hourly energy usage",
          data: [2, 2, 2, 2, 2,]
        },
        %{
          name: "Hourly energy usage",
          data: [2, 4, 6, 7, 8]
        }
      ]
    }

    json(conn, data)
  end
end
