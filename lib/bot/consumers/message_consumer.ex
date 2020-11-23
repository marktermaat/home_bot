defmodule HomeBot.Bot.MessageConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias HomeBot.Bot.RouteHandler

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    message = String.downcase(msg)

    cond do
      String.starts_with?(message, "version") ->
        HomeBot.Bot.VersionHandler.handle(:version, msg)

      String.starts_with?(message, "time to work") ->
        RouteHandler.handle(:time_to_work, msg)

      String.starts_with?(message, "time to home") ->
        RouteHandler.handle(:time_to_home, msg)

      String.starts_with?(message, "restart nginx") ->
        HomeBot.Bot.Host.HostCommandHandler.handle(:restart_nginx, msg)

      String.starts_with?(message, "speedtest") ->
        HomeBot.Bot.Host.HostCommandHandler.handle(:speedtest, msg)

      String.starts_with?(message, "help") ->
        Api.create_message(msg.channel_id, """
        - version
        - time to work
        - time to home
        - restart nginx
        - speedtest
        """)

      true ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
