defmodule HomeBot.Weather.TemperatureLogger do
  def run() do
    IO.puts("Downloading temperature: #{meteostats_api_key()}")
  end

  defp meteostats_api_key() do
    Application.fetch_env!(:home_bot, :meteostat_api_key)
  end
end
