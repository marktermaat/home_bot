defmodule HomeBot.DataStore.ChannelStore do
  @table_name "homebot_data"
  @table_key "channel_subscriptions"

  def add_subscriber(channel_id) do
    channels = get_subscribers()

    HomeBot.DataStore.Store.store_item(
      @table_name,
      @table_key,
      Enum.uniq(channels ++ [channel_id])
    )
  end

  def get_subscribers() do
    case HomeBot.DataStore.Store.get_item(@table_name, @table_key) do
      :none -> []
      subscribers -> subscribers
    end
  end
end
