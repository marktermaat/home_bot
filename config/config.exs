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

# HomeBot configuration
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
  openweather_api_key: "FILL IN",
  influxdb_host: "FILL IN",
  influxdb_port: 1,
  hashed_password: "FILL IN",
  rss_router_host: "FILL IN",
  rss_router_api_token: "SECRET",
  healthchecks_host: "FILL IN",
  solar_edge_api_key: "FILL IN",
  mqtt_client_id: "HomeBot",
  mqtt_host: "localhost",
  mqtt_port: 1883

# Homebot DB configuration
config :home_bot,
  db_hostname: "localhost",
  db_port: 5432,
  db_username: "postgres",
  db_password: "postgres",
  db_database: "postgres"

# Quantum schedules
config :home_bot, HomeBot.Scheduler,
  jobs: [
    {"*/30 * * * *", {HomeBot.Weather, :log_temperature_data, []}},
    {"0 */4 * * * *", {HomeBot.Monitoring, :run_monitoring_job, []}},
    {"0 5 * * * *", {HomeBot.Monitoring, :run_daily_energy_monitoring, []}},
    {"*/15 * * * *", {HomeJobs.SolarEdge.GetSolarEdgeQuarterDataJob, :run, []}},
    {"5 2 * * * *", {HomeJobs.SolarEdge.GetSolarEdgeDailyDataJob, :run, []}}
    {"0 * * * *", {HomeJobs.SolarEdge.GetSolarEdgeTelemetryDataJob, :run, []}},
  ]

# InfluxDB
config :home_bot, HomeBot.DataStore.InfluxConnection,
  recv_timeout: 60_000,
  init: {HomeBot.DataStore.InfluxInit, :initialize_influx}

# Phoenix
config :phoenix, :json_library, Jason

config :home_bot, HomeWeb.Endpoint, pubsub_server: HomeWeb.PubSub

import_config "#{Mix.env()}.exs"
