defmodule HomeWeb.ApiHomeClimateController do
  use HomeWeb, :controller

  alias HomeBot.DataStore

  def recent_temperature(conn, _params) do
    result = DataStore.get_recent_home_climate_data()

    labels = result |> Enum.map(&Map.fetch!(&1, :time))
    values = result |> Enum.map(&Map.fetch!(&1, :temperature))

    data = %{
      title: "Temperature",
      labels: labels,
      datasets: [
        %{
          name: "Temperature",
          data: values
        }
      ]
    }

    json(conn, data)
  end

  def recent_humidity(conn, _params) do
    result = DataStore.get_recent_home_climate_data()

    labels = result |> Enum.map(&Map.fetch!(&1, :time))
    values = result |> Enum.map(&Map.fetch!(&1, :humidity))

    data = %{
      title: "Humidity",
      labels: labels,
      datasets: [
        %{
          name: "Humidity",
          data: values
        }
      ]
    }

    json(conn, data)
  end
end
