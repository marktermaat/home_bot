defmodule HomeBot.Monitoring.MonitoringJob do
  @moduledoc "This job will check if everything is still in order on the server"

  def run do
    check_feeds()
    check_smart_meter()
    check_weather_data()
  end

  defp check_feeds do
    feeds = HomeBot.Rss.get_feeds()
    |> Enum.map(fn {key, value} -> {key, DateTime.from_iso8601(value)} end)
    |> Enum.map(fn {feed, {:ok, dt, _}} -> {feed, dt} end)

    # Check RssRoutere in genereal
    {_feed, latest_timestamp} = feeds |> Enum.max_by(fn {_feed, dt} -> dt end)
    if Timex.before?(latest_timestamp, Timex.shift(Timex.now, hours: -6)) do
      HomeBot.Bot.notify_users("RssRouter has not been updated since #{latest_timestamp}")
    end

    # Check specific feeds
    feeds
    |> Enum.filter(fn {_feed, dt} -> Timex.before?(dt, Timex.shift(Timex.now, days: -7)) end)
    |> Enum.each(fn {feed, dt} -> HomeBot.Bot.notify_users("#{feed} has not been updated since #{dt}") end)
  end

  defp check_smart_meter do
    %{"time" => time} = HomeBot.DataStore.get_latest_energy_measurement()
    {:ok, latest_timestamp, _} = DateTime.from_iso8601(time)

    if Timex.before?(latest_timestamp, Timex.shift(Timex.now, minutes: -5)) do
      HomeBot.Bot.notify_users("Smart meter data not received since #{latest_timestamp}")
    end
  end

  defp check_weather_data do
    %{"time" => time} = HomeBot.DataStore.get_latest_weather_data()
    {:ok, latest_timestamp, _} = DateTime.from_iso8601(time)

    if Timex.before?(latest_timestamp, Timex.shift(Timex.now, hours: -4)) do
      HomeBot.Bot.notify_users("Weather data not received since #{latest_timestamp}")
    end
  end
end
