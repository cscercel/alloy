defmodule Alloy.Accounts.Account do
  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :name, :string
    field :type, :string

    many_to_many :users, Alloy.Accounts.User, join_through: Alloy.Accounts.AccountUser
    has_many :transactions, Alloy.Budgets.Transaction

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account, attrs) do
    account
    |> cast(attrs, [:name, :type])
    |> validate_required([:name, :type])
    |> validate_inclusion(:type, ["personal", "joint"])
  end
end
