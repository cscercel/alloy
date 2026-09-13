defmodule Alloy.Budgets do
  @moduledoc """
  The Budgets context.
  """

  import Ecto.Query, warn: false
  alias Ecto.Adapter.Transaction
  alias Ecto.Adapter.Transaction
  alias Ecto.Adapter.Transaction
  alias Ecto.Adapter.Transaction
  alias Alloy.Repo

  alias Alloy.Budgets.Transaction
  alias Alloy.Accounts.{Scope, AccountUser}

  @doc """
  Subscribes to scoped notifications about any transaction changes.

  The broadcasted messages match the pattern:

    * {:created, %Transaction{}}
    * {:updated, %Transaction{}}
    * {:deleted, %Transaction{}}

  """
  def subscribe_transactions(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Alloy.PubSub, "user:#{key}:transactions")
  end

  defp broadcast_transaction(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Alloy.PubSub, "user:#{key}:transactions", message)
  end

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions(scope)
      [%Transaction{}, ...]

  """
  def list_transactions(%Scope{} = scope) do
    Repo.all(
      from t in Transaction,
        join: au in AccountUser,
        on: au.account_id == t.account_id,
        where: au.user_id == ^scope.user.id,
        order_by: [desc: t.date]
    )
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(scope, 123)
      %Transaction{}

      iex> get_transaction!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(%Scope{} = scope, id) do
    Repo.one!(
      from t in Transaction,
        join: au in AccountUser,
        on: au.account_id == t.account_id,
        where: au.user_id == ^scope.user.id and t.id == ^id
    )
  end

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(scope, %{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(%Scope{} = scope, attrs) do
    attrs = Map.put(attrs, "user_id", scope.user.id)

    with {:ok, transaction = %Transaction{}} <-
           %Transaction{}
           |> Transaction.changeset(attrs)
           |> Repo.insert() do
      broadcast_transaction(scope, {:created, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(scope, transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(scope, transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Scope{} = scope, %Transaction{} = transaction, attrs) do
    _ = get_transaction!(scope, transaction.id)

    with {:ok, transaction = %Transaction{}} <-
           transaction
           |> Transaction.changeset(attrs)
           |> Repo.update() do
      broadcast_transaction(scope, {:updated, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(scope, transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(scope, transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Scope{} = scope, %Transaction{} = transaction) do
    _ = get_transaction!(scope, transaction.id)

    with {:ok, transaction = %Transaction{}} <- Repo.delete(transaction) do
      broadcast_transaction(scope, {:deleted, transaction})
      {:ok, transaction}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(scope, transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Scope{} = scope, %Transaction{} = transaction, attrs \\ %{}) do
    if transaction.id, do: _ = get_transaction!(scope, transaction.id)
    Transaction.changeset(transaction, attrs)
  end

  @doc """
    Returns a summary of income and expense totals for a given account,
    scoped to the given month, for accounts the scoped user belongs to.

    Amounts are returned in cents. If there are no matching transactions,
    both totals will be `nil`.

    ## Examples

      iex> monthly_summary(scope, account_id, 2026, 9)
      %{income: 150000, expense: 92000}

      iex> monthly_summary(scope, account_id_with_no_activity, 2026, 9)
      %{income: nil, expense: nil}

  """

  def monthly_summary(%Scope{} = scope, account_id, year, month) do
    start_date = Date.new!(year, month, 1)
    end_date = Date.end_of_month(start_date)

    Repo.one(
      from t in Transaction,
        join: au in AccountUser,
        on: au.account_id == t.account_id,
        where: au.user_id == ^scope.user.id,
        where: t.account_id == ^account_id,
        where: t.date >= ^start_date and t.date <= ^end_date,
        select: %{
          income: sum(fragment("CASE WHEN ? = 'income' THEN ? ELSE 0 END", t.type, t.amount)),
          expense: sum(fragment("CASE WHEN ? = 'expense' THEN ? ELSE 0 END", t.type, t.amount))
        }
    )
  end

  # Temp
  alias Alloy.Budgets.Category

  def list_categories do
    Repo.all(Category)
  end
end
