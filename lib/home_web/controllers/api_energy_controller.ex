defmodule HomeWeb.ApiEnergyController do
  use HomeWeb, :controller

  alias HomeWeb.Models.GraphModel

  def gas_usage(conn, %{"group" => group, "start" => start_time, "end" => end_time}) do
    validate_group(group)
    validate_timestamp(start_time)
    validate_timestamp(end_time)

    data = GraphModel.gas_usage_data(group, start_time, end_time)

    json(conn, data)
  end

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

  def electricity_usage(conn, %{"group" => group, "start" => start_time, "end" => end_time}) do
    validate_group(group)
    validate_timestamp(start_time)
    validate_timestamp(end_time)

    data = GraphModel.electricity_usage_data(group, start_time, end_time)

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

  defp validate_group(group) do
    case Enum.member?(~w(1m 15m 1h 6h 1d 7d), group) do
      true -> nil
      _ -> raise "Unknown group_by"
    end
  end

  defp validate_timestamp(timestamp) do
    case DateTime.from_iso8601(timestamp) do
      {:ok, _, _} -> nil
      _ -> raise "Incorrect timestamp format"
    end
  end
end
