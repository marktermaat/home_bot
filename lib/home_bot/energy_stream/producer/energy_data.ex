defmodule HomeBot.EnergyStream.Producer.EnergyData do
  def get_new_data(latest_measurement) do
    data = HomeBot.DataStore.get_measurements_since(latest_measurement)
    latest_measurement = get_last_time(data) |> parse_time || latest_measurement

    {data, latest_measurement}
  end

  defp get_last_time(data) do
    data
    |> List.last()
    |> get_in(["time"])
  end

  defp parse_time(nil), do: nil
  defp parse_time(time) do
    {:ok, dt, _} = DateTime.from_iso8601(time)
    Timex.shift(dt, milliseconds: 1)
  end
end
