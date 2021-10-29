defmodule HomeWeb.HomeTemperatureLive do
  use HomeWeb, :live_view

  @one_minute_in_ms 10_000

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
    home_temperature = get_home_temperature()

    socket
    |> assign(:value, home_temperature)
    |> assign(:unit, " °C")
  end

  defp get_home_temperature() do
    HomeBot.DataStore.get_current_home_temperature()
  end
end
