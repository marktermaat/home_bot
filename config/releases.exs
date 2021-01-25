import Config

config :nostrum, token: System.fetch_env!("HOME_BOT_DISCORD_TOKEN")

config :home_bot,
  google_maps_key: System.fetch_env!("HOME_BOT_GOOGLE_MAPS_KEY"),
  home_address: System.fetch_env!("HOME_BOT_HOME_ADDRESS"),
  work_address: System.fetch_env!("HOME_BOT_WORK_ADDRESS"),
  ssh_host: System.fetch_env!("HOME_BOT_SERVER_SSH_HOST"),
  ssh_username: System.fetch_env!("HOME_BOT_SERVER_SSH_USERNAME"),
  ssh_password: System.fetch_env!("HOME_BOT_SERVER_SSH_PASSWORD"),
  meteostat_api_key: System.fetch_env!("HOME_BOT_METEOSTAT_API_KEY"),
  influxdb_host: System.fetch_env!("HOME_BOT_INFLUXDB_HOST"),
  influxdb_port: System.fetch_env!("HOME_BOT_INFLUXDB_PORT")