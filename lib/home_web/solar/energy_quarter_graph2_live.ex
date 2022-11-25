defmodule HomeWeb.EnergyQuarterGraph2Live do
  use HomeWeb, :live_view

  # alias HomeWeb.Solar.SolarPageUpdates

  @impl true
  def render(assigns) do
    ~L"""
    <div style="width:80%; height: 500px" id="graph" phx-hook="VegaLite" phx-update="ignore" data-id="<%= @id%>"/>
    """
  end

  @impl true
  def mount(_params, %{"user_id" => _user_id}, socket) do
    _old_spec = get_fake_spec()
    spec = HomeWeb.Grapher.stacked_grouped_bar_chart(1)
    socket = assign(socket, id: socket.id)
    {:ok, push_event(socket, "vega_lite:#{socket.id}:init", %{"spec" => spec})}
  end

  defp get_fake_spec() do
    VegaLite.new(title: "Demo", width: :container, height: :container, padding: 5)
    # Load values. Values are a map with the attributes to be used by Vegalite
    |> VegaLite.data_from_values(fake_data())
    # Defines the type of mark to be used
    |> VegaLite.mark(:line)
    # Sets the axis, the key for the data and the type of data
    |> VegaLite.encode_field(:x, "date", type: :nominal)
    |> VegaLite.encode_field(:y, "total", type: :quantitative)
    # Output the specifcation
    |> VegaLite.to_spec()
  end

  defp fake_data do
    today = Date.utc_today()
    until = today |> Date.add(10)

    Enum.map(Date.range(today, until), fn date ->
      %{total: Enum.random(1..100), date: Date.to_iso8601(date), name: "potato"}
    end)
  end
end
