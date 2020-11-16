defmodule HomeBot.Bot.RouteHandler do
  alias Nostrum.Api

  @home_address Application.fetch_env!(:home_bot, :home_address)
  @work_address Application.fetch_env!(:home_bot, :work_address)

  def handle(:time_to_work, msg) do
    seconds = HomeBot.Bot.Routes.GoogleMapsApi.get_trip_duration(@home_address, @work_address)
    Api.create_message(msg.channel_id, "Time to work right now is #{seconds / 60} minutes")
  end

  def handle(:time_to_home, msg) do
    seconds = HomeBot.Bot.Routes.GoogleMapsApi.get_trip_duration(@work_address, @home_address)
    Api.create_message(msg.channel_id, "Time to home right now is #{seconds / 60} minutes")
  end
end
