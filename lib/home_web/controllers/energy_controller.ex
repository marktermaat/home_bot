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

  def show_graph(conn, params) do
    IO.inspect(params)
    render(conn, "show.html")
  end
end
