import Config

# Logging
config :logger,
  backends: [:console, {LoggerFileBackend, :error_log}]

config :logger, :console, level: :all

config :logger, :error_log,
  level: :error,
  path: "#{System.get_env("LOG_PATH") || "log"}/error.log"

# App
config :nostrum, token: "FILL_IN"

config :home_bot,
  data_path: "./data",
  google_maps_key: "FILL IN",
  home_address: "FILL IN",
  work_address: "FILL IN",
  ssh_host: "FILL IN",
  ssh_username: "FILL IN",
  ssh_password: "FILL IN",
  meteostat_api_key: "FILL IN"

config :home_bot, HomeBot.Scheduler,
  jobs: [
    {"* * * * *", {HomeBot.Weather.TemperatureLogger, :run, []}}
  ]

import_config "#{Mix.env()}.exs"
import_config "#{Mix.env()}.secret.exs"
