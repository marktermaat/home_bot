defmodule HomeBot.Bot.VersionHandler do
  @behaviour HomeBot.Bot.CommandHandler

  alias Nostrum.Api

  @impl HomeBot.Bot.CommandHandler
  def handle(:version, msg) do
    Api.create_message(msg.channel_id, "0.1.0")
  end
end
