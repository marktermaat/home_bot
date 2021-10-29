defmodule HomeBot do
  use Application

  def start(_type, _args) do
    postgres_child_spec = {
      Postgrex,
      [
        hostname: Application.fetch_env!(:home_bot, :db_hostname),
        port: Application.fetch_env!(:home_bot, :db_port),
        username: Application.fetch_env!(:home_bot, :db_username),
        password: Application.fetch_env!(:home_bot, :db_password),
        database: Application.fetch_env!(:home_bot, :db_database),
        name: HomeBot.DbConnection,
        show_sensitive_data_on_connection_error: true
      ]
    }

    children = [
      HomeBot.Bot,
      HomeBot.Scheduler,
      HomeBot.DataStore.InfluxConnection,
      {Phoenix.PubSub, [name: HomeWeb.PubSub, adapter: Phoenix.PubSub.PG2]},
      HomeWeb.Endpoint,
      postgres_child_spec
      # HomeBot.EnergyStream.Supervisor
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
