defmodule HomeBot.Bot.Host.HostCommandHandler do
  @moduledoc "A command handler for shell commands on the host"

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

  def handle(:speedtest, msg) do
    Api.create_message(msg.channel_id, "Performing speedtest...")

    result = HomeBot.Bot.Host.execute("speedtest-cli")

    download_speed_str = Enum.find(result, fn s -> String.contains?(s, "Download:") end)

    download_speed =
      Regex.named_captures(~r/.*: (?<speed>.*) Mbit.*/, download_speed_str)
      |> Map.get("speed")

    upload_speed_str = Enum.find(result, fn s -> String.contains?(s, "Upload:") end)

    upload_speed =
      Regex.named_captures(~r/.*: (?<speed>.*) Mbit.*/, upload_speed_str)
      |> Map.get("speed")

    Api.create_message(msg.channel_id, "Download speed: #{download_speed} Mbit/second")
    Api.create_message(msg.channel_id, "Upload speed: #{upload_speed} Mbit/second")
  end
end
