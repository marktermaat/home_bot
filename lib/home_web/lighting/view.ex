defmodule HomeWeb.LightingView do
  use HomeWeb, :feature_view

  def state_color(state) do
    case state do
      :on -> "green"
      :off -> "red"
      :disabled -> "grey"
    end
  end

  def vacation_mode_color(state) do
    case state do
      true -> "green"
      false -> "red"
    end
  end

  def format_time(time) do
    Time.to_iso8601(time)
  end
end
