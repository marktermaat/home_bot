defmodule HomeBot.Bot.MainHandler do
  use Nostrum.Consumer

  alias Nostrum.Api

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "version" ->
        Api.create_message(msg.channel_id, "0.01")

      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
