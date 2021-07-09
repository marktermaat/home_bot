defmodule Finance.TransactionsTest do
  use HomeBot.DataCase

  alias Finance.Transactions

  import Finance.TransactionFixtures

  describe "upsert_transaction" do
    test "upserts new transactions" do
      transaction = valid_transaction()
      Transactions.upsert_transaction(transaction)

      transactions = Transactions.list_transactions()
      assert length(transactions) == 1
    end

    test "skips existing transactions" do
      transaction = valid_transaction()
      Transactions.upsert_transaction(transaction)
      Transactions.upsert_transaction(transaction)

      transactions = Transactions.list_transactions()
      assert length(transactions) == 1
    end
  end
end
