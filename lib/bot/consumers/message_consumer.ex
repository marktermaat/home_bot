defmodule HomeBot.Bot.MessageConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias HomeBot.Bot.RouteHandler

  def start_link do
    Consumer.start_link(__MODULE__)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    case msg.content do
      "version" ->
        HomeBot.Bot.VersionHandler.handle(:version, msg)

      "time to work" ->
        RouteHandler.handle(:time_to_work, msg)

      "time to home" ->
        RouteHandler.handle(:time_to_home, msg)

      "restart nginx" ->
        HomeBot.Bot.Host.HostCommandHandler.handle(:restart_nginx, msg)

      "help" ->
        Api.create_message(msg.channel_id, """
        - version
        - time to work
        - time to home
        - restart nginx
        """)

      _ ->
        :ignore
    end
  end

  def handle_event(_event) do
    :noop
  end
end
