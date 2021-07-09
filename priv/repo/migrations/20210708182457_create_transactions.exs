defmodule HomeBot.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :timestamp, :naive_datetime
      add :description, :string
      add :account, :string
      add :sign, :integer
      add :amount, :decimal
      add :corrected_amount, :decimal

      timestamps()
    end

    create unique_index(:transactions, [:timestamp, :description, :account])
  end
end
