defmodule HomeBot.Monitoring.MonitoringJob do
  @moduledoc "This job will check if everything is still in order on the server"

  def run do
    # check_feeds()

    if !check_smart_meter() || !check_weather_data() || !check_solar_data() do
      HomeBot.Bot.Host.execute("cd /docker/event-data-storer && docker-compose restart")
    end

    notify_healthchecks()
  end

  # defp check_feeds do
  #   feeds =
  #     HomeBot.Rss.get_feeds()
  #     |> Enum.map(fn {key, value} -> {key, DateTime.from_iso8601(value)} end)
  #     |> Enum.map(fn {feed, {:ok, dt, _}} -> {feed, dt} end)

  #   # Check RssRouter in general
  #   {_feed, latest_timestamp} = feeds |> Enum.max_by(fn {_feed, dt} -> DateTime.to_unix(dt) end)

  #   if Timex.before?(latest_timestamp, Timex.shift(Timex.now(), hours: -6)) do
  #     HomeBot.Bot.notify_users("RssRouter has not been updated since #{latest_timestamp}")
  #   end

  #   # Check specific feeds
  #   # feeds
  #   # |> Enum.filter(fn {_feed, dt} -> Timex.before?(dt, Timex.shift(Timex.now, days: -30)) end)
  #   # |> Enum.each(fn {feed, dt} -> HomeBot.Bot.notify_users("#{feed} has not been updated since #{dt}") end)
  # end

  defp check_smart_meter do
    %{time: latest_timestamp} = HomeBot.DataStore.get_latest_energy_measurement()

    if Timex.before?(latest_timestamp, Timex.shift(Timex.now(), minutes: -5)) do
      HomeBot.Bot.notify_users("Smart meter data not received since #{latest_timestamp}")
      false
    else
      true
    end
  end

  defp check_weather_data do
    latest_timestamp = HomeWeather.Api.get_latest_weather_record().timestamp

    if Timex.before?(latest_timestamp, Timex.shift(Timex.now(), hours: -4)) do
      HomeBot.Bot.notify_users("Weather data not received since #{latest_timestamp}")
      false
    else
      true
    end
  end

  defp check_solar_data do
    latest_timestamp = HomeSolar.Api.get_latest_record().timestamp

    if Timex.before?(latest_timestamp, Timex.shift(Timex.now(), hours: -4)) do
      HomeBot.Bot.notify_users("Solar data not received since #{latest_timestamp}")
      false
    else
      true
    end
  end

  defp notify_healthchecks do
    HTTPoison.start()

    %HTTPoison.Response{status_code: 200} = HTTPoison.get!(healthchecks_host())
  end

  defp healthchecks_host do
    Application.fetch_env!(:home_bot, :healthchecks_host)
  end
end
