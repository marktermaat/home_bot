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
    data = GraphModel.gas_usage_data("1h", days_ago(3), now(), "Hourly gas usage")

    json(conn, data)
  end

  @spec daily_gas_usage(Plug.Conn.t(), any) :: Plug.Conn.t()
  def daily_gas_usage(conn, _params) do
    data = GraphModel.gas_usage_data("1d", days_ago(48), now(), "Daily gas usage")

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
    data = GraphModel.electricity_usage_data("1d", days_ago(48), now(), "Daily electricity usage")

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

  def compare_gas_usage(conn, %{"p1start" => p1_start, "p1end" => p1_end, "p2start" => p2_start, "p2end" => p2_end, "ticks" => ticks}) do
    {p1_mean, p1_sd} = GraphModel.get_gas_mean_and_sd_of_period(p1_start, p1_end, ticks)
    {p2_mean, p2_sd} = GraphModel.get_gas_mean_and_sd_of_period(p2_start, p2_end, ticks)

    data = %{
      title: "Gas hourly usage comparison",
      labels: ["Period 1 mean", "Period 1 SD", "Period 2 mean", "Period 2 SD"],
      datasets: [
        %{
          data: [p1_mean, p1_sd, p2_mean, p2_sd]
        },
      ]
    }

    json(conn, data)
  end

  def compare_electricity_usage(conn, %{"p1start" => p1_start, "p1end" => p1_end, "p2start" => p2_start, "p2end" => p2_end, "ticks" => ticks}) do
    {p1_mean, p1_sd} = GraphModel.get_electricity_mean_and_sd_of_period(p1_start, p1_end, ticks)
    {p2_mean, p2_sd} = GraphModel.get_electricity_mean_and_sd_of_period(p2_start, p2_end, ticks)

    data = %{
      title: "Electricity hourly usage comparison",
      labels: ["Period 1 mean", "Period 1 SD", "Period 2 mean", "Period 2 SD"],
      datasets: [
        %{
          data: [p1_mean, p1_sd, p2_mean, p2_sd]
        },
      ]
    }

    json(conn, data)
  end

  defp days_ago(days) do
    DateTime.now!("Etc/UTC") |> DateTime.add(-days * 24 * 60 * 60, :second) |> DateTime.to_iso8601()
  end

  defp now do
    DateTime.now!("Etc/UTC") |> DateTime.to_iso8601()
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
