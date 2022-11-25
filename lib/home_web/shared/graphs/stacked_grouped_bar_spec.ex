defmodule HomeWeb.Graph.StackedGroupedBarSpec do
  defstruct [
    :title,
    :data,
    :group_field
  ]

  @type t :: %HomeWeb.Graph.StackedGroupedBarSpec{
          title: String.t(),
          data: {atom(), any()},
          group_field: String.t()
        }
end
