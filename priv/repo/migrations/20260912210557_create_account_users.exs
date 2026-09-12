defmodule Alloy.Repo.Migrations.CreateAccountUsers do
  use Ecto.Migration

  def change do
    create table(:account_users) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:account_users, [:account_id])
    create index(:account_users, [:user_id])
    create unique_index(:account_users, [:account_id, :user_id])
  end
end
