defmodule HomeLight.Mqtt.SmartLightEventHandler do
  use Tortoise.Handler

  def init([light_name, pid]) do
    {:ok, [light_name: light_name, caller_pid: pid]}
  end

  def connection(_status, state) do
    {:ok, state}
  end

  def handle_message(topic, payload, state) do
    light_name = state[:light_name]
    ["zigbee2mqtt", ^light_name] = topic
    data = Jason.decode!(payload)
    HomeLight.SmartLightController.update_state(state[:caller_pid], data)
    {:ok, state}
  end

  def subscription(_status, _topic_filter, state) do
    {:ok, state}
  end

  def terminate(_reason, _state) do
    :ok
  end
end
