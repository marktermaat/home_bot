defmodule HomeBot.Weather do
  def log_temperature_data() do
    HomeBot.Weather.TemperatureLogger.run()
  end
end
