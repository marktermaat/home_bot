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
      chart_name: "time_barchart.html",
      uri: uri,
      graph_type: params["graph_type"],
      group: params["group_by"],
      start: params["start"],
      end: params["end"]
    )
  end

  def compare_graph(conn, %{"energy" => params}) do
    graph_query_params = [
      p1start: params["period1_start"] |> Date.from_iso8601!() |> Date.to_iso8601(),
      p1end: params["period1_end"] |> Date.from_iso8601!() |> Date.to_iso8601(),
      p2start: params["period2_start"] |> Date.from_iso8601!() |> Date.to_iso8601(),
      p2end: params["period2_end"] |> Date.from_iso8601!() |> Date.to_iso8601(),
      ticks: params
        |> Enum.filter(fn {key, _value} -> String.starts_with?(key, "hours_") end)
        |> Enum.filter(fn {_key, value} -> value == "true" end)
        |> Enum.map(fn {key, _value} -> String.slice(key, 6..-1//1) end)
        |> Enum.join(",")
    ]

    uri = compare_graph_type_to_path(params["graph_type"], graph_query_params)

    render(conn, "compare.html", chart_name: "barchart.html", uri: uri, input: params)
  end

  defp graph_type_to_path(graph_type, query_params) do
    case graph_type do
      "gas_usage" ->
        Routes.api_energy_path(HomeWeb.Endpoint, :gas_usage, query_params)

      "electricity_usage" ->
        Routes.api_energy_path(HomeWeb.Endpoint, :electricity_usage, query_params)
    end
  end

  defp compare_graph_type_to_path(graph_type, query_params) do
    case graph_type do
      "gas_usage" ->
        Routes.api_energy_path(HomeWeb.Endpoint, :compare_gas_usage, query_params)

      "electricity_usage" ->
        Routes.api_energy_path(HomeWeb.Endpoint, :compare_electricity_usage, query_params)
    end
  end
end
