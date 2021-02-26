defmodule HomeWeb.EnergyController do
  use HomeWeb, :controller

  def gas(conn, _params) do
    render(conn, "gas.html")
  end

  def electricity(conn, _params) do
    render(conn, "electricity.html")
  end

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def compare(conn, _params) do
    render(conn, "compare.html")
  end

  def show_graph(conn, %{"energy" => params}) do
    # "energy" => %{
    #   "graph_type" => "gas_usage",
    #   "group_by" => "minute",
    #   "start" => "st",
    #   "end" => "end"
    # }

    graph_query_params = [
      group: params["group_by"],
      start:
        params["start"]
        |> NaiveDateTime.from_iso8601!()
        |> DateTime.from_naive!("Etc/UTC")
        |> DateTime.to_iso8601(),
      end:
        params["end"]
        |> NaiveDateTime.from_iso8601!()
        |> DateTime.from_naive!("Etc/UTC")
        |> DateTime.to_iso8601()
    ]

    uri = graph_type_to_path(params["graph_type"], graph_query_params)

    render(conn, "show.html",
      chart_name: "barchart.html",
      uri: uri,
      graph_type: params["graph_type"],
      group: params["group_by"],
      start: params["start"],
      end: params["end"]
    )
  end

  defp graph_type_to_path(graph_type, query_params) do
    case graph_type do
      "gas_usage" ->
        Routes.api_energy_path(HomeWeb.Endpoint, :gas_usage, query_params)

      "electricity_usage" ->
        Routes.api_energy_path(HomeWeb.Endpoint, :electricity_usage, query_params)
    end
  end
end
