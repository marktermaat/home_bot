defmodule HomeWeb.EnergyController do
  use HomeWeb, :controller

  def hourly_gas_usage(conn, _params) do
    result = HomeBot.DataStore.get_gas_usage_per_hour()
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
    result = HomeBot.DataStore.get_gas_usage_per_day()
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
