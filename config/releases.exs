import Config

config :nostrum, token: System.fetch_env!("HOME_BOT_DISCORD_TOKEN")

config :home_bot, HomeWeb.Endpoint,
  url: [
    host: System.fetch_env!("HOME_WEB_HOST")
  ],
  http: [port: 4001],
  secret_key_base: System.fetch_env!("HOME_WEB_SECRET_KEY_BASE"),
  live_view: [signing_salt: System.fetch_env!("HOME_WEB_SECRET_KEY_BASE")],
  server: true

config :home_bot,
  data_path: System.fetch_env!("DATA_PATH"),
  google_maps_key: System.fetch_env!("HOME_BOT_GOOGLE_MAPS_KEY"),
  home_address: System.fetch_env!("HOME_BOT_HOME_ADDRESS"),
  work_address: System.fetch_env!("HOME_BOT_WORK_ADDRESS"),
  ssh_host: System.fetch_env!("HOME_BOT_SERVER_SSH_HOST"),
  ssh_username: System.fetch_env!("HOME_BOT_SERVER_SSH_USERNAME"),
  ssh_password: System.fetch_env!("HOME_BOT_SERVER_SSH_PASSWORD"),
  meteostat_api_key: System.fetch_env!("HOME_BOT_METEOSTAT_API_KEY"),
  openweather_api_key: System.fetch_env!("HOME_BOT_OPENWEATHER_API_KEY"),
  influxdb_host: System.fetch_env!("HOME_BOT_INFLUXDB_HOST"),
  influxdb_port: System.fetch_env!("HOME_BOT_INFLUXDB_PORT"),
  hashed_password: System.fetch_env!("HOME_BOT_HASHED_PASSWORD"),
  rss_router_host: System.fetch_env!("RSS_ROUTER_HOST"),
  rss_router_api_token: System.fetch_env!("RSS_ROUTER_API_TOKEN"),
  healthchecks_host: System.fetch_env!("HOME_BOT_HEALTHCHECKS_HOST"),
  db_hostname: System.fetch_env!("HOMEBOT_DB_HOST"),
  db_port: System.fetch_env!("HOMEBOT_DB_PORT"),
  db_username: System.fetch_env!("HOMEBOT_DB_USERNAME"),
  db_password: System.fetch_env!("HOMEBOT_DB_PASSWORD"),
  db_database: System.fetch_env!("HOMEBOT_DB_DATABASE"),
  solar_edge_api_key: System.fetch_env!("SOLAR_EDGE_API_KEY"),
  mqtt_host: System.fetch_env!("MQTT_HOST"),
  mqtt_port: System.fetch_env!("MQTT_PORT")
