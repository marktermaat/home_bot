defmodule HomeBot.Bot.VersionHandler do
  alias Nostrum.Api

  def handle(:version, msg) do
    Api.create_message(msg.channel_id, "0.01")
  end
end
