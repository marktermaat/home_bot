defmodule HomeWeb.Grapher do
  alias HomeWeb.Graph.StackedGroupedBarSpec

  @spec stacked_grouped_bar_chart(StackedGroupedBarSpec.t()) :: any()
  def stacked_grouped_bar_chart(_spec) do
    data = [
      %{timestamp: NaiveDateTime.from_iso8601!("2022-01-01 00:00:00"), a: 1, b: 2, group: "g1"},
      %{timestamp: NaiveDateTime.from_iso8601!("2022-01-01 00:00:00"), a: 3, b: 4, group: "g2"},
      %{timestamp: NaiveDateTime.from_iso8601!("2022-01-02 00:00:00"), a: 3, b: 4, group: "g1"}
    ]

    VegaLite.new(title: "Demo", width: :container, height: :container, padding: 5)
    # Load values. Values are a map with the attributes to be used by Vegalite
    |> VegaLite.data_from_values(data)
    |> VegaLite.layers([
      VegaLite.new()
      |> VegaLite.mark(:bar, size: 30)
      |> VegaLite.encode_field(:x, "timestamp", type: :nominal)
      |> VegaLite.encode_field(:y, "a", type: :quantitative)
      |> VegaLite.encode_field(:x_offset, "group")
      |> VegaLite.encode_field(:color, "group", type: :nominal),
      VegaLite.new()
      |> VegaLite.mark(:bar, size: 30)
      |> VegaLite.encode_field(:x, "timestamp", type: :nominal)
      |> VegaLite.encode_field(:y, "b", type: :quantitative)
      |> VegaLite.encode_field(:x_offset, "group")
      |> VegaLite.encode_field(:color, "group", type: :nominal)
    ])
    |> VegaLite.to_spec()
  end
end
