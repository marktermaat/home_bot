defmodule HomeBot.Tools do
  @moduledoc "Tools and helper functions"

  @doc """
  This will perform an inner join on the given lists of maps. It will map on the given key.
  """
  @spec join_on_key(list(map), list(map), String.t() | atom) :: list(map)
  def join_on_key(list1, list2, key) do
    join_on_key(list1, list2, key, key)
  end

  @doc """
  This will perform an inner join on the given lists of maps. It will map on the given key.
  """
  @spec join_on_key(list(map), list(map), String.t() | atom(), String.t() | atom()) :: list(map)
  def join_on_key(list1, list2, key1, key2) do
    Enum.map(list1, fn item1 ->
      case Enum.find(list2, fn item2 -> Map.fetch!(item1, key1) == Map.fetch!(item2, key2) end) do
        nil -> nil
        item2 -> Map.merge(item1, item2)
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  This will perform an inner join on the given lists of maps. It will map using the access functions given
  """
  @spec join_on_fn(list(map), list(map), fun(), fun()) :: list(map)
  def join_on_fn(list1, list2, access_fn1, access_fn2) do
    Enum.map(list1, fn item1 ->
      case Enum.find(list2, fn item2 -> access_fn1.(item1) == access_fn2.(item2) end) do
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

  @spec mean_for_key(list(map), String.t() | atom()) :: float()
  def mean_for_key(list, key) do
    Enum.reduce(list, 0, fn item, acc -> acc + item[key] end) / length(list)
  end

  @spec mean(list) :: float()
  def mean(values) do
    Enum.sum(values) / length(values)
  end

  @spec standard_deviation(list, float()) :: float()
  def standard_deviation(values, mean) do
    variance =
      values
      |> Enum.map(fn x -> :math.pow(mean - x, 2) end)
      |> Enum.sum()

    :math.sqrt(variance / (length(values) - 1))
  end
end
