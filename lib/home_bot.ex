defmodule HomeBot do
  use Application

  @impl true
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
        show_sensitive_data_on_connection_error: true,
        pool_size: 4
      ]
    }

    client_id = Application.fetch_env!(:home_bot, :mqtt_client_id)
    host = Application.fetch_env!(:home_bot, :mqtt_host)
    port = String.to_integer("#{Application.fetch_env!(:home_bot, :mqtt_port)}")

    tortoise_spec = {
      Tortoise.Connection,
      [
        client_id: client_id,
        server: {Tortoise.Transport.Tcp, host: host, port: port},
        handler: {Tortoise.Handler.Logger, []}
      ]
    }

    children = [
      HomeBot.Bot,
      HomeBot.Scheduler,
      HomeBot.DataStore.InfluxConnection,
      {Phoenix.PubSub, [name: HomeWeb.PubSub, adapter: Phoenix.PubSub.PG2]},
      HomeLight.HomeLightSupervisor,
      HomeWeb.Endpoint,
      postgres_child_spec,
      tortoise_spec
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  @impl true
  def stop(_) do
    IO.puts("Too many exceptions, stopping application")
    System.stop()
  end
end
