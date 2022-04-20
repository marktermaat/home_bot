defmodule HomeWeb.SmartLightToggleLive do
  use HomeWeb, :live_view

  alias HomeLight.SmartLightController

  def render(assigns) do
    render(HomeWeb.LightingView, "smart_light_widget.html", assigns)
  end

  def mount(_params, %{"name" => name}, socket) do
    if connected?(socket), do: Process.send_after(self(), :update, 1_000)
    controller_pid = SmartLightController.get_pid(name)
    state = get_state(controller_pid)
    {:ok, assign(socket, name: name, controller_pid: controller_pid, state: state)}
  end

  def handle_info(:update, socket) do
    Process.send_after(self(), :update, 1_000)
    state = get_state(socket.assigns.controller_pid)
    {:noreply, assign(socket, state: state)}
  end

  def handle_event("toggle_light", _value, socket) do
    toggle_light(socket.assigns.controller_pid)
    state = get_state(socket.assigns.controller_pid)
    {:noreply, assign(socket, state: state)}
  end

  defp get_state(pid) do
    SmartLightController.get_state(pid)
  end

  defp toggle_light(pid) do
    case get_state(pid) do
      :on -> SmartLightController.turn_off(pid)
      :off -> SmartLightController.turn_on(pid)
    end
  end
end
