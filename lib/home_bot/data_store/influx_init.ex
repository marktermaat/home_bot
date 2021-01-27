defmodule HomeBot.DataStore.InfluxInit do

  @spec initialize_influx(module) :: :ok
  def initialize_influx(conn) do
    config =
      Keyword.merge(
        conn.config(),
        host: Application.fetch_env!(:home_bot, :influxdb_host),
        port: String.to_integer(Application.fetch_env!(:home_bot, :influxdb_port))
      )

    Application.put_env(:home_bot, conn, config)
  end
end
