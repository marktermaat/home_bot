defmodule HomeLight.Holiday.Store do
  alias HomeBot.DataStore.Store

  @table_name "home_light"
  @table_key "holiday"

  def store_state(state) do
    Store.store_item(@table_name, @table_key, state)
  end

  def get_state() do
    case Store.get_item(@table_name, @table_key) do
      # Create new state
      :none -> {false, {nil, nil}}
      holiday_state -> holiday_state
    end
  end
end
