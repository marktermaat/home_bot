defmodule HomeBot do
  use Application

  def start(_type, _args) do
    children = [
      HomeBot.Bot,
      HomeBot.Scheduler,
      HomeBot.DataStore.InfluxConnection,
      {Phoenix.PubSub, [name: HomeWeb.PubSub, adapter: Phoenix.PubSub.PG2]},
      HomeWeb.Endpoint
      # HomeBot.EnergyStream.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
