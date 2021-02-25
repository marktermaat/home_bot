defmodule HomeWeb.ApiEnergyController do
  use HomeWeb, :controller

  alias HomeWeb.Models.GraphModel

  def hourly_gas_usage(conn, _params) do
    data = GraphModel.hourly_gas_usage_data()

    json(conn, data)
  end

  def daily_gas_usage(conn, _params) do
    data = GraphModel.daily_gas_usage_data()

    json(conn, data)
  end

  def daily_gas_and_temp(conn, _params) do
    data = GraphModel.daily_gas_and_temperature_data()

    json(conn, data)
  end

  def gas_usage_per_temperature(conn, _params) do
    data = GraphModel.gas_usage_per_temperature_data()

    json(conn, data)
  end

  def gas_usage_per_temperature_per_year(conn, _params) do
    data = GraphModel.gas_usage_per_temperature_per_year_data()

    json(conn, data)
  end

  def daily_electricity_usage(conn, _params) do
    data = GraphModel.daily_electricity_usage_data()

    json(conn, data)
  end

  def hourly_electricity_usage(conn, _params) do
    data = GraphModel.hourly_electricity_usage_data()

    json(conn, data)
  end

  def current_electricity_usage(conn, _params) do
    data = GraphModel.current_electricity_usage_data()

    json(conn, data)
  end
end
