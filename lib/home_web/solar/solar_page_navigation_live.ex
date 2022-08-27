defmodule HomeWeb.SolarPageNavigationLive do
  # In Phoenix v1.6+ apps, the line below should be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  alias HomeWeb.Solar.SolarPageUpdates

  def render(assigns) do
    ~L"""
    <div>
      <span>Previous</span>
      <span phx-click="month">Month</span>
      <span phx-click="week">Week</span>
      <span phx-click="day">Day</span>
      <span phx-click="hour">Hour</span>
      <span>Next</span>
    </div>
    """
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    {:ok, assign(socket, :user_id, user_id)}
  end

  def handle_event("hour", _value, socket) do
    SolarPageUpdates.notify(
      socket.assigns.user_id,
      {[:solar_navigation, :time_range], [minutes_ago(60), now_iso8601(), :minute]}
    )

    {:noreply, socket}
  end

  def handle_event("day", _value, socket) do
    SolarPageUpdates.notify(
      socket.assigns.user_id,
      {[:solar_navigation, :time_range], [hours_ago(24), now_iso8601(), :hour]}
    )

    {:noreply, socket}
  end

  def handle_event("week", _value, socket) do
    SolarPageUpdates.notify(
      socket.assigns.user_id,
      {[:solar_navigation, :time_range],
       ["#{days_ago(7)}T00:00:00Z", "#{today()}T00:00:00Z", :day]}
    )

    {:noreply, socket}
  end

  def handle_event("month", _value, socket) do
    SolarPageUpdates.notify(
      socket.assigns.user_id,
      {[:solar_navigation, :time_range],
       ["#{days_ago(31)}T00:00:00Z", "#{today()}T00:00:00Z", :day]}
    )

    {:noreply, socket}
  end

  defp today(), do: Date.utc_today() |> Date.to_iso8601()
  defp days_ago(i), do: Date.add(Date.utc_today(), -i) |> Date.to_iso8601()

  defp now_iso8601(),
    do: Timex.now("Europe/Amsterdam") |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()

  defp now(),
    do: Timex.now("Europe/Amsterdam") |> DateTime.to_naive()

  defp hours_ago(i),
    do:
      now()
      |> NaiveDateTime.add(-i * 60 * 60, :second)
      |> NaiveDateTime.to_iso8601()

  defp minutes_ago(i),
    do:
      now()
      |> NaiveDateTime.add(-i * 60, :second)
      |> NaiveDateTime.to_iso8601()
end
