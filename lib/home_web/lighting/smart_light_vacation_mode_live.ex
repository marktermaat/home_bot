defmodule HomeWeb.SmartLightVacationModeLive do
  use HomeWeb, :live_view

  def render(assigns) do
    render(HomeWeb.LightingView, "vacation_mode_widget.html", assigns)
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, :timer.seconds(1))
    {:ok, update_state(socket)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, :timer.seconds(1))
    {:noreply, update_state(socket)}
  end

  def handle_event("toggle_vacation_mode", _value, socket) do
    toggle_vacation_mode(socket.assigns.state)
    {:noreply, update_state(socket)}
  end

  defp toggle_vacation_mode(state) do
    case state do
      true -> HomeLight.Holiday.Service.end_holiday()
      false -> HomeLight.Holiday.Service.start_holiday()
    end
  end

  defp update_state(socket) do
    {state, {start_time, end_time}} = HomeLight.Holiday.Service.get_state()
    assign(socket, state: state, start_time: start_time, end_time: end_time)
  end

end
