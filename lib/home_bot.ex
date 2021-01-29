defmodule HomeBot do
  use Application

  def start(_type, _args) do
    children = [
      HomeBot.Bot,
      HomeBot.Scheduler,
      HomeBot.DataStore.InfluxConnection,
      HomeWeb.Endpoint
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
