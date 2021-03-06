defmodule HomeWeb.ElectricityTodayVsAverageLive do
  @moduledoc "The LiveView for the widget that shows Electricity usage of yesterday vs the average of the last week"

  use HomeWeb, :live_view

  def render(assigns) do
    render(HomeWeb.WidgetView, "svg_plot.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, plot: get_plot())}
  end

  defp get_plot do
    {start_timestamp, end_timestamp} = get_range_timestamps()

    data = HomeBot.DataStore.get_electricity_usage("1d", start_timestamp, end_timestamp)

    sum = data
    |> Enum.take(7)
    |> Enum.reduce(0, fn x, acc -> acc + x["low_tariff_usage"] + x["normal_tariff_usage"] end)
    average = sum / 7

    yesterday_value = List.last(data)["low_tariff_usage"] + List.last(data)["normal_tariff_usage"]

    ds = Contex.Dataset.new([{"Week average", average}, {"Yesterday", yesterday_value}], ["x", "y"])
    Contex.Plot.new(ds, Contex.BarChart, 400, 200, title: "Electricity", colour_palette: ["645ad3"]) |> Contex.Plot.to_svg
  end

  defp get_range_timestamps do
    now = Timex.now("Europe/Amsterdam")
    end_timestamp = Timex.beginning_of_day(now)
    start_timestamp = Timex.shift(end_timestamp, days: -8)

    t1 = start_timestamp
    |> Timex.Timezone.convert("UTC")
    |> DateTime.to_iso8601

    t2 = end_timestamp
    |> Timex.Timezone.convert("UTC")
    |> DateTime.to_iso8601

    {t1, t2}
  end
end
