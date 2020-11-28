defmodule HomeBot.Bot.RouteHandler do
  @behaviour HomeBot.Bot.CommandHandler

  alias Nostrum.Api

  @impl HomeBot.Bot.CommandHandler
  def handle(:time_to_work, msg) do
    seconds = HomeBot.Bot.Routes.GoogleMapsApi.get_trip_duration(home_address(), work_address())

    Api.create_message(
      msg.channel_id,
      "Time to work right now is #{Float.round(seconds / 60, 1)} minutes"
    )
  end

  @impl HomeBot.Bot.CommandHandler
  def handle(:time_to_home, msg) do
    seconds = HomeBot.Bot.Routes.GoogleMapsApi.get_trip_duration(home_address(), work_address())

    Api.create_message(
      msg.channel_id,
      "Time to home right now is #{Float.round(seconds / 60, 1)} minutes"
    )
  end

  defp home_address() do
    Application.fetch_env!(:home_bot, :home_address)
  end

  defp work_address() do
    Application.fetch_env!(:home_bot, :work_address)
  end
end
