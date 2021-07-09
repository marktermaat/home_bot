import Config

config :home_bot, :children, [
      HomeWeb.Endpoint,
      Finance.Repo
    ]

config :home_bot, Finance.Repo,
  database: "data/test_database.db",
  pool: Ecto.Adapters.SQL.Sandbox
