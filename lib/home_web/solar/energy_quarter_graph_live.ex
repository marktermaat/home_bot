defmodule HomeWeb.EnergyQuarterGraphLive do
  @moduledoc "Shows the energy and solar data of the last 12 hours in quarters"

  use HomeWeb, :live_view

  def render(assigns) do
    render(HomeWeb.WidgetView, "svg_plot.html", assigns)
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, plot: get_daily_plot())}
  end

  def handle_event("zoom_day", %{"category" => category}, socket) do
    now = Date.utc_today()
    [day, month] = String.split(category, "-") |> Enum.map(&String.to_integer/1)

    date =
      if month > now.month do
        Date.new!(now.year - 1, month, day)
      else
        Date.new!(now.year, month, day)
      end

    {:noreply, assign(socket, plot: get_hourly_plot(date), date: date)}
  end

  def handle_event("zoom_hour", %{"category" => category}, socket) do
    date = socket.assigns.date
    [hour, _] = String.split(category, ":") |> Enum.map(&String.to_integer/1)

    {:noreply, assign(socket, plot: get_quarterly_plot(date, hour))}
  end

  def handle_event("zoom_quarter", _params, socket) do
    {:noreply, socket}
  end

  defp get_daily_plot() do
    end_date = Date.utc_today()
    {:ok, end_time} = NaiveDateTime.new(end_date, ~T[00:00:00])
    start_date = Date.add(end_date, -14)
    {:ok, start_time} = NaiveDateTime.new(start_date, ~T[00:00:00])

    data =
      HomeEnergy.Api.get_energy_usage(start_time, end_time, 1, :day)
      |> Enum.map(fn record ->
        date =
          record.start_time
          |> then(fn d -> "#{d.day}-#{d.month}" end)

        {date, record.usage_total_tariff - record.supplied_total_tariff}
      end)

    ds = Contex.Dataset.new(data, ["x", "y"])

    create_plot(ds, "zoom_day")
  end

  defp get_hourly_plot(date) do
    start_time = NaiveDateTime.new!(date, ~T[00:00:00])
    end_time = NaiveDateTime.new!(Date.add(date, 1), ~T[00:00:00])

    # HomeEnergy.Api.get_energy_usage(start_time, end_time, 15, :minutes)
    data =
      HomeEnergy.Api.get_energy_usage(start_time, end_time, 1, :hour)
      |> Enum.map(fn record ->
        time =
          record.start_time
          |> NaiveDateTime.to_time()
          |> Time.truncate(:second)
          |> then(fn t ->
            "#{t.hour}:#{t.minute |> Integer.to_string() |> String.pad_trailing(2, "0")}"
          end)

        {time, record.usage_total_tariff - record.supplied_total_tariff}
      end)

    ds = Contex.Dataset.new(data, ["x", "y"])

    create_plot(ds, "zoom_hour", "#{date}")
  end

  defp get_quarterly_plot(date, hour) do
    start_time = NaiveDateTime.new!(date.year, date.month, date.day, hour - 1, 0, 0)
    end_time = NaiveDateTime.new!(date.year, date.month, date.day, hour + 2, 0, 0)

    # HomeEnergy.Api.get_energy_usage(start_time, end_time, 15, :minutes)
    data =
      HomeEnergy.Api.get_energy_usage(start_time, end_time, 15, :minutes)
      |> Enum.map(fn record ->
        time =
          record.start_time
          |> NaiveDateTime.to_time()
          |> Time.truncate(:second)
          |> then(fn t ->
            "#{t.hour}:#{t.minute |> Integer.to_string() |> String.pad_trailing(2, "0")}"
          end)

        {time, record.usage_total_tariff - record.supplied_total_tariff}
      end)

    ds = Contex.Dataset.new(data, ["x", "y"])

    create_plot(ds, "zoom_quarter", "#{date}")
  end

  defp create_plot(dataset, event_handler, subtitle \\ "") do
    {min, max} =
      dataset.data
      |> Enum.map(fn {_, value} -> value end)
      |> Enum.min_max()

    custom_value_scale =
      Contex.ContinuousLinearScale.new()
      |> Contex.ContinuousLinearScale.domain(min, max)

    options = [
      data_labels: false,
      orientation: :vertical,
      colour_palette: HomeWeb.Shared.Graph.colour_palette(),
      phx_event_handler: event_handler,
      custom_value_scale: custom_value_scale
    ]

    plot =
      Contex.Plot.new(dataset, Contex.BarChart, 1000, 400, options)
      |> Contex.Plot.titles("Energy usage and generation", subtitle)
      |> Contex.Plot.axis_labels("Time", "Energy")
      |> Contex.Plot.plot_options(%{})

    Contex.Plot.to_svg(plot)
  end
end
