defmodule HomeBot.DataStore.PostgresStore do
  @moduledoc "Helpers for Postgres data stores"

  def query(query, args \\ []) do
    result = Postgrex.query!(HomeBot.DbConnection, query, args)

    result_to_map(result)
  end

  def result_to_map(%Postgrex.Result{columns: _columns, rows: []}) do
    []
  end

  def result_to_map(%Postgrex.Result{columns: columns, rows: rows}) do
    columns = columns |> Enum.map(&String.to_atom/1)

    rows
    |> Enum.map(fn row -> Enum.zip(columns, row) end)
    |> Enum.map(fn item -> Enum.into(item, %{}) end)
  end
end
