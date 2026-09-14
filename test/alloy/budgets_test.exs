defmodule Alloy.BudgetsTest do
  use Alloy.DataCase

  alias Alloy.Budgets

  describe "transactions" do
    alias Alloy.Budgets.Transaction

    import Alloy.AccountsFixtures, only: [user_scope_fixture: 0]
    import Alloy.BudgetsFixtures

    @invalid_attrs %{type: nil, date: nil, description: nil, amount: nil}

    test "list_transactions/1 returns all scoped transactions" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      other_transaction = transaction_fixture(other_scope)
      assert Budgets.list_transactions(scope) == [transaction]
      assert Budgets.list_transactions(other_scope) == [other_transaction]
    end

    test "get_transaction!/2 returns the transaction with given id" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      other_scope = user_scope_fixture()
      assert Budgets.get_transaction!(scope, transaction.id) == transaction
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_transaction!(other_scope, transaction.id) end
    end

    test "create_transaction/2 with valid data creates a transaction" do
      valid_attrs = %{type: "some type", date: ~D[2026-09-11], description: "some description", amount: 42}
      scope = user_scope_fixture()

      assert {:ok, %Transaction{} = transaction} = Budgets.create_transaction(scope, valid_attrs)
      assert transaction.type == "some type"
      assert transaction.date == ~D[2026-09-11]
      assert transaction.description == "some description"
      assert transaction.amount == 42
      assert transaction.user_id == scope.user.id
    end

    test "create_transaction/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Budgets.create_transaction(scope, @invalid_attrs)
    end

    test "update_transaction/3 with valid data updates the transaction" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      update_attrs = %{type: "some updated type", date: ~D[2026-09-12], description: "some updated description", amount: 43}

      assert {:ok, %Transaction{} = transaction} = Budgets.update_transaction(scope, transaction, update_attrs)
      assert transaction.type == "some updated type"
      assert transaction.date == ~D[2026-09-12]
      assert transaction.description == "some updated description"
      assert transaction.amount == 43
    end

    test "update_transaction/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)

      assert_raise MatchError, fn ->
        Budgets.update_transaction(other_scope, transaction, %{})
      end
    end

    test "update_transaction/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Budgets.update_transaction(scope, transaction, @invalid_attrs)
      assert transaction == Budgets.get_transaction!(scope, transaction.id)
    end

    test "delete_transaction/2 deletes the transaction" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert {:ok, %Transaction{}} = Budgets.delete_transaction(scope, transaction)
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_transaction!(scope, transaction.id) end
    end

    test "delete_transaction/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert_raise MatchError, fn -> Budgets.delete_transaction(other_scope, transaction) end
    end

    test "change_transaction/2 returns a transaction changeset" do
      scope = user_scope_fixture()
      transaction = transaction_fixture(scope)
      assert %Ecto.Changeset{} = Budgets.change_transaction(scope, transaction)
    end
  end

  describe "categories" do
    alias Alloy.Budgets.Category

    import Alloy.AccountsFixtures, only: [user_scope_fixture: 0]
    import Alloy.BudgetsFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/1 returns all scoped categories" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      category = category_fixture(scope)
      other_category = category_fixture(other_scope)
      assert Budgets.list_categories(scope) == [category]
      assert Budgets.list_categories(other_scope) == [other_category]
    end

    test "get_category!/2 returns the category with given id" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      other_scope = user_scope_fixture()
      assert Budgets.get_category!(scope, category.id) == category
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_category!(other_scope, category.id) end
    end

    test "create_category/2 with valid data creates a category" do
      valid_attrs = %{name: "some name"}
      scope = user_scope_fixture()

      assert {:ok, %Category{} = category} = Budgets.create_category(scope, valid_attrs)
      assert category.name == "some name"
      assert category.user_id == scope.user.id
    end

    test "create_category/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Budgets.create_category(scope, @invalid_attrs)
    end

    test "update_category/3 with valid data updates the category" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Budgets.update_category(scope, category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      category = category_fixture(scope)

      assert_raise MatchError, fn ->
        Budgets.update_category(other_scope, category, %{})
      end
    end

    test "update_category/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Budgets.update_category(scope, category, @invalid_attrs)
      assert category == Budgets.get_category!(scope, category.id)
    end

    test "delete_category/2 deletes the category" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      assert {:ok, %Category{}} = Budgets.delete_category(scope, category)
      assert_raise Ecto.NoResultsError, fn -> Budgets.get_category!(scope, category.id) end
    end

    test "delete_category/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      category = category_fixture(scope)
      assert_raise MatchError, fn -> Budgets.delete_category(other_scope, category) end
    end

    test "change_category/2 returns a category changeset" do
      scope = user_scope_fixture()
      category = category_fixture(scope)
      assert %Ecto.Changeset{} = Budgets.change_category(scope, category)
    end
  end
end
