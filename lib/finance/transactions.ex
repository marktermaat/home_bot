defmodule Finance.Transactions do
  alias Finance.Schema.Transaction
  alias Finance.Repo

  def upsert_transaction(attrs \\ %{}) do
    %Transaction{}
    |> Transaction.changeset(attrs)
    |> Repo.insert!(on_conflict: :nothing)
  end

  def list_transactions() do
    Repo.all(Transaction)
  end
end
