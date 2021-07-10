defmodule HomeWeb.FinanceController do
  use HomeWeb, :controller

  alias Finance.Transactions

  def transactions(conn, _params) do
    transactions = Transactions.list_transactions()
    render(conn, "transactions.html", transactions: transactions)
  end
end
