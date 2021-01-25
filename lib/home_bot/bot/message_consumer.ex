defmodule HomeBot.Bot.MessageConsumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias HomeBot.Bot.RouteHandler

  def start_link do
    IO.puts("Starting new Message Consumer")
    notify("HomeBot started [#{Application.get_env(:home_bot, :env)}]")
    Consumer.start_link(__MODULE__)
  end

  def notify(msg) do
    HomeBot.DataStore.get_subscribers()
    |> Enum.each(fn channel_id -> Api.create_message(channel_id, msg) end)
  end

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    message = String.downcase(msg.content)

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

      String.starts_with?(message, "register") ->
        HomeBot.Bot.Monitoring.MonitoringCommandHandler.handle(:register, msg)

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
