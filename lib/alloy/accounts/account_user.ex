defmodule Alloy.Accounts.AccountUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "account_users" do
    belongs_to :account, Alloy.Accounts.Account
    belongs_to :user, Alloy.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(account_user, attrs) do
    account_user
    |> cast(attrs, [:account_id, :user_id])
    |> validate_required([:account_id, :user_id])
    |> foreign_key_constraint(:account_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:account_id, :user_id])
  end
end
