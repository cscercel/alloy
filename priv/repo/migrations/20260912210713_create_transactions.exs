defmodule Alloy.Repo.Migrations.CreateTransactions do
  use Ecto.Migration

  def change do
    create table(:transactions) do
      add :amount, :integer, null: false
      add :description, :string
      add :date, :date, null: false
      add :type, :string, null: false
      add :transfer_id, :uuid

      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :nilify_all)
      add :category_id, references(:categories, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:transactions, [:account_id])
    create index(:transactions, [:user_id])
    create index(:transactions, [:category_id])
    create index(:transactions, [:transfer_id])
  end
end
