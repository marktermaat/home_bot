defmodule HomeWeb.EnergyController do
  use HomeWeb, :controller

  def hourly_gas_usage(conn, _params) do
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
