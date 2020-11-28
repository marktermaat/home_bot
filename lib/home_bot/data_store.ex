defmodule HomeBot.DataStore do
  def add_subscriber(channel_id) do
    HomeBot.DataStore.ChannelStore.add_subscriber(channel_id)
  end

  def get_subscribers() do
    HomeBot.DataStore.ChannelStore.get_subscribers()
  end
end
