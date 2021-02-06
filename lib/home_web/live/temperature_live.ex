defmodule HomeWeb.TemperatureLive do
  use HomeWeb, :live_view

  def render(assigns) do
    render(HomeWeb.WidgetView, "widget.html", assigns)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 10000)

    {timestamp, temperature} = get_temperature()

    socket = socket
      |> assign(:timestamp, timestamp)
      |> assign(:value, temperature)
      |> assign(:unit, " °C")

    {:ok, socket}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10000)
    {:noreply, assign(socket, :temperature, get_temperature())}
  end

  defp get_temperature() do
    latest = HomeBot.DataStore.get_latest_temperature()
    {:ok, timestamp} = NaiveDateTime.from_iso8601(latest["time"])

    {timestamp, latest["temperature"]}
  end
end
