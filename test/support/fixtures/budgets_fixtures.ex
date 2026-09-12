defmodule Alloy.BudgetsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Alloy.Budgets` context.
  """

  @doc """
  Generate a transaction.
  """
  def transaction_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        amount: 42,
        date: ~D[2026-09-11],
        description: "some description",
        type: "some type"
      })

    {:ok, transaction} = Alloy.Budgets.create_transaction(scope, attrs)
    transaction
  end
end
