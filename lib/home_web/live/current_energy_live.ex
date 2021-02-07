defmodule HomeWeb.CurrentEnergyLive do
  use HomeWeb, :live_view

  @ten_seconds_in_ms 10_000

  def render(assigns) do
    render(HomeWeb.WidgetView, "widget.html", assigns)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, @ten_seconds_in_ms)
    {:ok, update_socket(socket)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, @ten_seconds_in_ms)
    {:noreply, update_socket(socket)}
  end

  defp update_socket(socket) do
    current_energy_usage = get_current_energy()

    socket
      |> assign(:value, current_energy_usage)
      |> assign(:unit, " kWh")
  end

  defp get_current_energy() do
    latest = HomeBot.DataStore.get_latest_energy_measurement()

    latest["current_energy_usage"]
  end
end
