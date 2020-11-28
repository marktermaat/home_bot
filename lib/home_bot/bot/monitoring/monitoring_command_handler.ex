defmodule HomeBot.Bot.Monitoring.MonitoringCommandHandler do
  @behaviour HomeBot.Bot.CommandHandler

  alias Nostrum.Api

  @impl HomeBot.Bot.CommandHandler
  def handle(:register, msg) do
    HomeBot.DataStore.add_subscriber(msg.channel_id)
    Api.create_message(msg.channel_id, "Channel registered.")
  end
end
