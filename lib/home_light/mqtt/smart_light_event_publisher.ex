defmodule HomeLight.Mqtt.SmartLightEventPublisher do
  def request_state(name) do
    payload = ~s/{"state": "", "brightness": ""}/
    Tortoise.publish(client_id(), get_topic(name), payload)
  end

  def turn_on(name) do
    payload = ~s/{"state": "ON"}/
    Tortoise.publish(client_id(), set_topic(name), payload)
  end

  def turn_off(name) do
    payload = ~s/{"state": "OFF"}/
    Tortoise.publish(client_id(), set_topic(name), payload)
  end

  def client_id, do: Application.fetch_env!(:home_bot, :mqtt_client_id)
  def get_topic(name), do: "zigbee2mqtt/#{name}/get"
  def set_topic(name), do: "zigbee2mqtt/#{name}/set"
end
