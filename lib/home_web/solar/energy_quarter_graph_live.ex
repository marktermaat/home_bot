defmodule HomeWeb.EnergyQuarterGraphLive do
  @moduledoc "Shows the energy and solar data of the last 12 hours in quarters"

  use HomeWeb, :live_view

  alias HomeWeb.Solar.SolarPageUpdates

  def render(assigns) do
    render(HomeWeb.WidgetView, "svg_plot.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    SolarPageUpdates.subscribe(user_id)
    end_date = Date.utc_today() |> Date.to_iso8601()
    start_date = Date.add(Date.utc_today(), -31) |> Date.to_iso8601()

    {:ok,
     assign(socket, plot: create_plot("#{start_date}T00:00:00Z", "#{end_date}T00:00:00Z", "day"))}
  end

  def handle_info({[:solar_navigation, :time_range], [start_time, end_time, unit]}, socket) do
    {:noreply, assign(socket, plot: create_plot(start_time, end_time, unit))}
  end

  def create_plot(start_time_string, end_time_string, unit) do
    start_time = NaiveDateTime.from_iso8601!(start_time_string)
    end_time = NaiveDateTime.from_iso8601!(end_time_string)

    energy_data = get_energy_data(start_time, end_time, unit)
    solar_data = get_solar_data(start_time, end_time, unit)

    solar_data =
      solar_data ++ List.duplicate({0}, Enum.count(energy_data) - Enum.count(solar_data))

    data =
      List.zip([energy_data, solar_data])
      |> Enum.map(fn {{date, consumed, supplied}, {produced}} ->
        {date, consumed, supplied, consumed + produced - supplied, produced}
      end)

    ds =
      Contex.Dataset.new(data, [
        "x",
        "consumed",
        "supplied",
        "total_used",
        "produced"
      ])

    subtitle = create_subtitle(start_time, end_time, unit)

    create_plot(ds, subtitle)
  end

  defp create_subtitle(start_time, end_time, unit) when unit in ["day"] do
    "#{start_time |> NaiveDateTime.to_date() |> Date.to_iso8601()} - #{end_time |> NaiveDateTime.to_date() |> Date.to_iso8601()}"
  end

  defp create_subtitle(start_time, end_time, unit) when unit in ["hour"] do
    "#{start_time |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_string()} - #{end_time |> NaiveDateTime.truncate(:second) |> NaiveDateTime.to_string()}"
  end

  defp create_subtitle(start_time, end_time, _unit) do
    "#{start_time |> NaiveDateTime.to_time() |> Time.truncate(:second) |> Time.to_string()} - #{end_time |> NaiveDateTime.to_time() |> Time.truncate(:second) |> Time.to_string()}"
  end

  defp get_energy_data(start_time, end_time, unit) do
    HomeEnergy.Api.get_energy_usage(start_time, end_time, 1, unit)
    |> Enum.map(fn record ->
      {record.start_time, record.usage_total_tariff, record.supplied_total_tariff}
    end)
  end

  defp get_solar_data(start_time, end_time, unit) do
    HomeSolar.Api.get_power_produced(start_time, end_time, 1, unit)
    |> Enum.map(fn record ->
      {record.power_produced / 1000.0}
    end)
  end

  defp create_plot(dataset, subtitle) do
    min_time = dataset.data |> List.first() |> elem(0)
    max_time = dataset.data |> List.last() |> elem(0)

    x_scale =
      Contex.TimeScale.new()
      |> Contex.TimeScale.domain(min_time, max_time)
      |> Contex.TimeScale.interval_count(20)

    options = [
      mapping: %{
        x_col: "x",
        y_cols: ["consumed", "supplied", "total_used", "produced"]
      },
      smoothed: false,
      custom_x_scale: x_scale
    ]

    plot =
      Contex.Plot.new(dataset, Contex.LinePlot, 1000, 400, options)
      |> Contex.Plot.titles("Energy usage and generation", subtitle)
      |> Contex.Plot.axis_labels("Time", "Energy")
      |> Contex.Plot.plot_options(%{legend_setting: :legend_right})

    Contex.Plot.to_svg(plot)
  end
end
