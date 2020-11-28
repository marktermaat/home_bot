defmodule HomeBot.DataStore.Store do
  def store_item(table_name, key, item) do
    query(table_name, fn table ->
      :ok = :dets.insert(table, {key, item})
    end)
  end

  def get_item(table_name, key) do
    query(table_name, fn table ->
      result = :dets.lookup(table, key)

      case result do
        [{^key, value}] -> value
        [] -> :none
      end
    end)
  end

  defp query(table_name, fun) do
    table = get_table(table_name)

    try do
      fun.(table)
    after
      :dets.close(table)
    end
  end

  defp get_table(table_name) do
    File.mkdir_p(data_path())
    dets_file = data_path() <> "/" <> table_name
    {:ok, table} = :dets.open_file(to_charlist(dets_file), access: :read_write, type: :set)
    table
  end

  defp data_path() do
    Application.fetch_env!(:home_bot, :data_path)
  end
end
