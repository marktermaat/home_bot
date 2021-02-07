defmodule HomeWeb.WindspeedLive do
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
    wind_speed = get_wind_speed()

    socket
      |> assign(:value, wind_speed)
      |> assign(:unit, " km/h")
  end

  defp get_wind_speed() do
    latest = HomeBot.DataStore.get_latest_weather_data()

    latest["wind_speed"]
  end
end
