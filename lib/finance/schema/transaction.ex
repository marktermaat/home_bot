defmodule Finance.Schema.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :account, :string
    field :amount, :decimal
    field :corrected_amount, :decimal
    field :description, :string
    field :sign, :integer
    field :timestamp, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:timestamp, :description, :account, :sign, :amount, :corrected_amount])
    |> validate_required([:timestamp, :description, :account, :sign, :amount, :corrected_amount])
    |> unique_constraint([:timestamp, :description, :account])
  end
end
