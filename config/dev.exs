import Config

config :home_bot, HomeWeb.Endpoint,
  url: [host: "localhost"],
  http: [port: 4000],
  secret_key_base: "to_override_in_prod",
  live_view: [signing_salt: "SECRET_SALT"],
  code_reloader: true,
  live_reload: [
    interval: 100,
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif)$},
      ~r{lib/home_web/views/.*(ex)$},
      ~r{lib/home_web/templates/.*(eex)$}
    ]
  ]

config :home_bot, HomeBot.Scheduler,
  jobs: [
  ]

config :home_bot, Finance.Repo,
  database: "data/database.db"

import_config "dev.secret.exs"
