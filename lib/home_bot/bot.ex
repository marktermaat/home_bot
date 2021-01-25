defmodule HomeBot.Bot do
  use Supervisor

  def start_link(_args) do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_init_args) do
    children = [
      HomeBot.Bot.MessageConsumer
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end

  def notify_users(message) do
    HomeBot.Bot.MessageConsumer.notify(message)
  end
end
