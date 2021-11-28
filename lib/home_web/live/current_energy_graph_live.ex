defmodule HomeWeb.CurrentEnergyGraphLive do
  @moduledoc "Shows and updates the current energy usage of the last 5 minutes"

  use HomeWeb, :live_view

  @ten_seconds_in_ms 10_000

  def render(assigns) do
    render(HomeWeb.WidgetView, "svg_plot.html", assigns)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, @ten_seconds_in_ms)

    {:ok, assign(socket, plot: get_plot())}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, @ten_seconds_in_ms)
    {:noreply, assign(socket, plot: get_plot())}
  end

  defp get_plot do
    data =
      HomeBot.DataStore.get_electricity_usage(5)
      |> Enum.map(fn record -> [record[:time], Decimal.to_float(record[:usage])] end)

    ds = Contex.Dataset.new(data, ["x", "y"])

    Contex.Plot.new(ds, Contex.LinePlot, 640, 320,
      title: "Current electricity usage (kW)",
      colour_palette: ["645ad3"]
    )
    |> Contex.Plot.to_svg()
  end
end
