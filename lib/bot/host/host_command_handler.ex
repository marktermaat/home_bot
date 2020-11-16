defmodule HomeBot.Bot.Host.HostCommandHandler do
  @behaviour HomeBot.Bot.CommandHandler

  alias Nostrum.Api

  @impl HomeBot.Bot.CommandHandler
  def handle(:restart_nginx, msg) do
    Api.create_message(msg.channel_id, "Restarting nginx...")

    result =
      HomeBot.Bot.Host.execute("cd /docker/nginx-letsencrypt && docker-compose restart")
      |> Enum.at(1)
      |> String.replace("\e[1A\e[2K\r", "")
      |> String.replace("\e[32m", "")
      |> String.replace("\e[0m\r\e[1B", "")

    Api.create_message(msg.channel_id, result)
  end
end
