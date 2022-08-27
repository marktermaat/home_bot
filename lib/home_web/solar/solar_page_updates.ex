defmodule HomeWeb.Solar.SolarPageUpdates do
  @topic inspect(__MODULE__)

  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(HomeWeb.PubSub, topic(user_id), link: true)
  end

  def notify(user_id, message) do
    Phoenix.PubSub.broadcast(HomeWeb.PubSub, topic(user_id), message)
  end

  defp topic, do: @topic
  defp topic(user_id), do: topic() <> to_string(user_id)
end
