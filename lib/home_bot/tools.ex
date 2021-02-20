defmodule HomeBot.Tools do
  @moduledoc "Tools and helper functions"

  @doc """
  This will perform an inner join on the given lists of maps. It will map on the given key.
  """
  @spec join_on_key(list(map), list(map), String.t()) :: list(map)
  def join_on_key(list1, list2, key) do
    Enum.map(list1, fn(item1) ->
      case Enum.find(list2, fn(item2) -> item1[key] == item2[key] end) do
        nil -> nil
        item2 -> Map.merge(item1, item2)
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Calculates a mean value for a list of maps for a given map-key
  """
  def mean_for_key([], _key), do: 0

  @spec mean_for_key(list(map), String.t()) :: float()
  def mean_for_key(list, key) do
    Enum.reduce(list, 0, fn item, acc -> acc + item[key] end) / length(list)
  end
end
