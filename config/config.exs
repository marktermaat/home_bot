import Config

# Logging
config :logger,
  backends: [
    :console,
    {LoggerFileBackend, :error_log},
    {HomeBot.Bot.NotifierLogBackend, :notifier_log_backend}
  ]

config :logger, :console, level: :all

config :logger, :error_log,
  level: :error,
  path: "#{System.get_env("LOG_PATH") || "log"}/error.log"

# App
config :nostrum, token: "FILL_IN"

config :home_bot,
  env: Mix.env(),
  data_path: "./data",
  google_maps_key: "FILL IN",
  home_address: "FILL IN",
  work_address: "FILL IN",
  ssh_host: "FILL IN",
  ssh_username: "FILL IN",
  ssh_password: "FILL IN",
  meteostat_api_key: "FILL IN",
  influxdb_host: "FILL IN",
  influxdb_port: 1

# Quantum schedules
config :home_bot, HomeBot.Scheduler,
  jobs: [
    {"* * * * *", {HomeBot.Weather, :log_temperature_data, []}}
  ]

# InfluxDB
config :home_bot, HomeBot.DataStore.InfluxConnection,
  init: {HomeBot.DataStore.InfluxInit, :initialize_influx}

import_config "#{Mix.env()}.exs"
