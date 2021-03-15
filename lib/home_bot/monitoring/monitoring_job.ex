defmodule HomeBot.Monitoring.MonitoringJob do
  @moduledoc "This job will check if everything is still in order on the server"

  def run do
    check_feeds()
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
end
