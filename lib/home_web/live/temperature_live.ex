defmodule HomeWeb.TemperatureLive do
  use HomeWeb, :live_view

  @one_minute_in_ms 60000

  def render(assigns) do
    render(HomeWeb.WidgetView, "widget.html", assigns)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, @one_minute_in_ms)
    {:ok, update_socket(socket)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, @one_minute_in_ms)
    {:noreply, update_socket(socket)}
  end

  defp update_socket(socket) do
    temperature = get_temperature()

    socket
      |> assign(:value, temperature)
      |> assign(:unit, " °C")
  end

  defp get_temperature() do
    latest = HomeBot.DataStore.get_latest_temperature()

    latest["temperature"]
  end
end
