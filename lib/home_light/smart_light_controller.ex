defmodule HomeLight.SmartLightController do
  use GenServer

  alias HomeLight.Mqtt.SmartLightEventPublisher

  # Callbacks

  @spec get_pid(String.t()) :: pid()
  def get_pid(name) do
    case Registry.lookup(HomeLight.Controllers, name) do
      [{pid, _}] -> pid
      [] -> start_controller(name)
    end
  end

  @spec get_state(pid()) :: atom()
  def get_state(pid) do
    state = GenServer.call(pid, :get_state)

    case Map.get(state, "state", "DISABLED") do
      "ON" -> :on
      "OFF" -> :off
      "DISABLED" -> :disabled
    end
  end

  @spec turn_on(pid()) :: term()
  def turn_on(pid) do
    GenServer.call(pid, :turn_on)
  end

  @spec turn_off(pid()) :: term()
  def turn_off(pid) do
    GenServer.call(pid, :turn_off)
  end

  @spec update_state(pid(), %{}) :: term()
  def update_state(pid, data) do
    GenServer.call(pid, {:update_state, data})
  end

  # private helpers
  defp start_controller(light_name) do
    name = {:via, Registry, {HomeLight.Controllers, light_name}}

    {:ok, pid} = GenServer.start_link(HomeLight.SmartLightController, [light_name], name: name)

    pid
  end

  # Server
  @impl true
  def init([light_name]) do
    env = Application.fetch_env!(:home_bot, :mqtt_client_id)
    client_id = "smart_light_consumer_#{light_name}_#{env}"
    host = Application.fetch_env!(:home_bot, :mqtt_host)
    port = String.to_integer("#{Application.fetch_env!(:home_bot, :mqtt_port)}")

    {:ok, pid} =
      Tortoise.Connection.start_link(
        client_id: client_id,
        server: {Tortoise.Transport.Tcp, host: host, port: port},
        handler: {HomeLight.Mqtt.SmartLightEventHandler, [light_name, self()]},
        subscriptions: [{"zigbee2mqtt/#{light_name}", 1}]
      )

    SmartLightEventPublisher.request_state(light_name)
    {:ok, {light_name, pid, %{}}}
  end

  @impl true
  def handle_call(:turn_on, _from, state = {light_name, _, _}) do
    SmartLightEventPublisher.turn_on(light_name)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:turn_off, _from, state = {light_name, _, _}) do
    SmartLightEventPublisher.turn_off(light_name)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state = {_, _, light_state}) do
    {:reply, light_state, state}
  end

  @impl true
  def handle_call({:update_state, new_state}, _from, {light_name, handler_pid, _state}) do
    {:reply, :ok, {light_name, handler_pid, new_state}}
  end
end
