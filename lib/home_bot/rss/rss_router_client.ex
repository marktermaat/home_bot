defmodule HomeBot.Rss.RssRouterClient do
  @moduledoc "A client for the RssRouter client"

  def get_feeds do
    HTTPoison.start()

    %HTTPoison.Response{status_code: 200, body: body} =
      HTTPoison.get!(host(),
        "Authorization": api_token()
      )

    Jason.decode!(body)
  end

  def insert_feed(_url) do

  end

  def delete_feed(_url) do

  end

  defp host do
    Application.fetch_env!(:home_bot, :rss_router_host)
  end

  defp api_token do
    Application.fetch_env!(:home_bot, :rss_router_api_token)
  end
end
