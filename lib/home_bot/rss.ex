defmodule HomeBot.Rss do
  @moduledoc "The interface of the RSS Module"

  alias HomeBot.Rss.RssRouterClient

  def get_feeds do
    RssRouterClient.get_feeds()
  end

  def insert_feed(url) do
    RssRouterClient.insert_feed(url)
  end

  def delete_feed(url) do
    RssRouterClient.delete_feed(url)
  end
end
