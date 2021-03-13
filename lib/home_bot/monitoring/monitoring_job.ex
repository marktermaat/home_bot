defmodule HomeBot.Monitoring.MonitoringJob do
  @moduledoc "This job will check if everything is still in order on the server"

  def run do
    check_feeds()
  end

  defp check_feeds do
    HomeBot.Rss.get_feeds()
    |> Enum.map(fn {key, value} -> {key, DateTime.from_iso8601(value)} end)
    |> Enum.map(fn {feed, {:ok, dt, _}} -> {feed, dt} end)
    |> Enum.filter(fn {_feed, dt} -> Timex.before?(dt, Timex.shift(Timex.now, days: -3)) end)
    |> Enum.each(fn {feed, dt} -> HomeBot.Bot.notify_users("#{feed} has not been updated since #{dt}") end)
  end
end
