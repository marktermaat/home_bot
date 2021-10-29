defmodule HomeBot.DataStore.PostgresStore do
  @moduledoc "Helpers for Postgres data stores"

  def result_to_map(%Postgrex.Result{columns: _columns, rows: []}) do
    []
  end

  def result_to_map(%Postgrex.Result{columns: columns, rows: rows}) do
    columns = columns |> Enum.map(&String.to_atom/1)
    Enum.map(rows, fn row -> Enum.zip(columns, row) end)
  end

end
