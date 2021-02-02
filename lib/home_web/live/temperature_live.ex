defmodule HomeWeb.TemperatureLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <%= assigns[:temperature] %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 10000)

    {:ok, assign(socket, :temperature, get_temperature())}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 10000)
    {:noreply, assign(socket, :temperature, get_temperature())}
  end

  defp get_temperature() do
    latest = HomeBot.DataStore.get_latest_temperature()
    {:ok, temperature} = NaiveDateTime.from_iso8601(latest["time"])

    "#{temperature}: #{latest["temperature"]}°C"
  end
end
