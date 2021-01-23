defmodule HomeBot.DataStore.InfluxConnection do
  use Instream.Connection,
    config: [
      host: Application.fetch_env!(:home_bot, :influxdb_host),
      port: Application.fetch_env!(:home_bot, :influxdb_port)
    ]
end
