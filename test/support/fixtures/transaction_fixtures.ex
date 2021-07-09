defmodule Finance.TransactionFixtures do
  def valid_transaction(attrs \\ %{}) do
    Enum.into(attrs, %{
      timestamp: NaiveDateTime.local_now(),
        description: "test",
        account: "account",
        amount: 100,
        corrected_amount: 100,
        sign: 1
    })
  end
end
