defmodule Alloy.Budgets.Transaction do
  use Ecto.Schema
  import Ecto.Changeset

  schema "transactions" do
    field :amount, :integer
    field :description, :string
    field :date, :date
    field :type, :string
    field :transfer_id, Ecto.UUID

    belongs_to :account, Alloy.Accounts.Account
    belongs_to :user, Alloy.Accounts.User
    belongs_to :category, Alloy.Budgets.Category

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [
      :amount,
      :description,
      :date,
      :type,
      :transfer_id,
      :account_id,
      :user_id,
      :category_id
    ])
    |> validate_required([:amount, :date, :type, :account_id, :user_id])
    |> validate_inclusion(:type, ["income", "expense"])
    |> validate_number(:amount, greater_than: 0)
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:category_id)
  end
end
