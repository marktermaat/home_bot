defmodule HomeWeb.LightingView do
  use HomeWeb, :feature_view

  def state_color(state) do
    case state do
      :on -> "green"
      :off -> "red"
      :disabled -> "grey"
    end
  end
end
