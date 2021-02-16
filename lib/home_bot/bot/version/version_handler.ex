defmodule HomeBot.Bot.VersionHandler do
  @behaviour HomeBot.Bot.CommandHandler

  alias Nostrum.Api

  @impl HomeBot.Bot.CommandHandler
  def handle(:version, msg) do
    {:ok, version} = :application.get_key(:home_bot, :vsn)
    Api.create_message(msg.channel_id, version)
  end
end
