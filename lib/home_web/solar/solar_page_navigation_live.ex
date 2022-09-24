defmodule HomeWeb.SolarPageNavigationLive do
  # In Phoenix v1.6+ apps, the line below should be: use MyAppWeb, :live_view
  use Phoenix.LiveView

  alias HomeWeb.Solar.SolarPageUpdates

  def render(assigns) do
    ~L"""
    <div>
      <span phx-click="previous">Previous</span>
      <span phx-click="year">Year</span>
      <span phx-click="month">Month</span>
      <span phx-click="week">Week</span>
      <span phx-click="day">Day</span>
      <span phx-click="hour">Hour</span>
      <span phx-click="next">Next</span>
    </div>
    """
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    {:ok, assign(socket, user_id: user_id, end_time: now(), period: :month)}
  end

  def handle_event("previous", _value, socket) do
    end_time = socket.assigns.end_time
    period = socket.assigns.period
    new_end_time = shift_end_time_back(end_time, period)
    send_page_update(socket.assigns.user_id, new_end_time, period)
    {:noreply, assign(socket, end_time: new_end_time)}
  end

  def handle_event("next", _value, socket) do
    end_time = socket.assigns.end_time
    period = socket.assigns.period
    new_end_time = shift_end_time_forward(end_time, period)
    send_page_update(socket.assigns.user_id, new_end_time, period)
    {:noreply, assign(socket, end_time: new_end_time)}
  end

  def handle_event("hour", _value, socket) do
    end_time = socket.assigns.end_time
    send_page_update(socket.assigns.user_id, end_time, :hour)
    {:noreply, assign(socket, period: :hour)}
  end

  def handle_event("day", _value, socket) do
    end_time = socket.assigns.end_time
    send_page_update(socket.assigns.user_id, end_time, :day)
    {:noreply, assign(socket, period: :day)}
  end

  def handle_event("week", _value, socket) do
    end_time = socket.assigns.end_time
    send_page_update(socket.assigns.user_id, end_time, :week)
    {:noreply, assign(socket, period: :week)}
  end

  def handle_event("month", _value, socket) do
    end_time = socket.assigns.end_time
    send_page_update(socket.assigns.user_id, end_time, :month)
    {:noreply, assign(socket, period: :month)}
  end

  def handle_event("year", _value, socket) do
    end_time = socket.assigns.end_time
    send_page_update(socket.assigns.user_id, end_time, :year)
    {:noreply, assign(socket, period: :year)}
  end

  defp send_page_update(user_id, end_time, :hour) do
    SolarPageUpdates.notify(
      user_id,
      {[:solar_navigation, :time_range],
       [shift_minutes(end_time, -60) |> iso8601, iso8601(end_time), :minute]}
    )
  end

  defp send_page_update(user_id, end_time, :day) do
    SolarPageUpdates.notify(
      user_id,
      {[:solar_navigation, :time_range],
       [shift_hours(end_time, -24) |> iso8601, iso8601(end_time), :hour]}
    )
  end

  defp send_page_update(user_id, end_time, :week) do
    SolarPageUpdates.notify(
      user_id,
      {[:solar_navigation, :time_range],
       ["#{shift_days(end_time, -7) |> NaiveDateTime.to_date}T00:00:00Z", "#{end_time |> NaiveDateTime.to_date}T00:00:00Z", :day]}
    )
  end

  defp send_page_update(user_id, end_time, :month) do
    SolarPageUpdates.notify(
      user_id,
      {[:solar_navigation, :time_range],
       [
         "#{shift_days(end_time, -31) |> NaiveDateTime.to_date()}T00:00:00Z",
         "#{end_time |> NaiveDateTime.to_date()}T00:00:00Z",
         :day
       ]}
    )
  end

  defp send_page_update(user_id, end_time, :year) do
    SolarPageUpdates.notify(
      user_id,
      {[:solar_navigation, :time_range],
       [
         "#{shift_days(end_time, -365) |> NaiveDateTime.to_date()}T00:00:00Z",
         "#{end_time |> NaiveDateTime.to_date()}T00:00:00Z",
         :month
       ]}
    )
  end

  defp shift_end_time_back(end_time, period) do
    case period do
      :hour -> shift_minutes(end_time, -60)
      :day -> shift_hours(end_time, -24)
      :week -> shift_days(end_time, -7)
      :month -> shift_days(end_time, -31)
      :year -> shift_days(end_time, -365)
    end
  end

  defp shift_end_time_forward(end_time, period) do
    case period do
      :hour -> shift_minutes(end_time, 60)
      :day -> shift_hours(end_time, 24)
      :week -> shift_days(end_time, 7)
      :month -> shift_days(end_time, 31)
      :year -> shift_days(end_time, 365)
    end
  end

  defp now(), do: Timex.now("Europe/Amsterdam") |> DateTime.to_naive()
  defp iso8601(timestamp), do: timestamp |> NaiveDateTime.to_iso8601()

  defp shift_days(timestamp, i), do: timestamp |> NaiveDateTime.add(i * 60 * 60 * 24, :second)

  defp shift_hours(timestamp, i),
    do:
      timestamp
      |> NaiveDateTime.add(i * 60 * 60, :second)

  defp shift_minutes(timestamp, i),
    do:
      timestamp
      |> NaiveDateTime.add(i * 60, :second)
end
