defmodule AlloyWeb.TransactionLive.Form do
  use AlloyWeb, :live_view

  alias Alloy.Budgets
  alias Alloy.Budgets.Transaction
  alias Alloy.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage transaction records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="transaction-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:account_id]}
          type="select"
          label="Account"
          options={Enum.map(@accounts, &{&1.name, &1.id})}
        />
        <.input
          field={@form[:category_id]}
          type="select"
          label="Category"
          options={[{"Uncategorized", nil} | Enum.map(@categories, &{&1.name, &1.id})]}
        />
        <.input
          field={@form[:type]}
          type="select"
          label="Type"
          options={[{"Expense", "expense"}, {"Income", "income"}]}
        />
        <.input field={@form[:amount]} type="number" label="Amount (in cents)" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:date]} type="date" label="Date" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Transaction</.button>
          <.button navigate={return_path(@current_scope, @return_to, @transaction)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> assign(:accounts, Accounts.list_accounts(socket.assigns.current_scope))
     |> assign(:categories, Budgets.list_categories())
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    transaction = Budgets.get_transaction!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Transaction")
    |> assign(:transaction, transaction)
    |> assign(
      :form,
      to_form(Budgets.change_transaction(socket.assigns.current_scope, transaction))
    )
  end

  defp apply_action(socket, :new, _params) do
    transaction = %Transaction{}

    socket
    |> assign(:page_title, "New Transaction")
    |> assign(:transaction, transaction)
    |> assign(
      :form,
      to_form(Budgets.change_transaction(socket.assigns.current_scope, transaction))
    )
  end

  @impl true
  def handle_event("validate", %{"transaction" => transaction_params}, socket) do
    changeset =
      Budgets.change_transaction(
        socket.assigns.current_scope,
        socket.assigns.transaction,
        transaction_params
      )

    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"transaction" => transaction_params}, socket) do
    save_transaction(socket, socket.assigns.live_action, transaction_params)
  end

  defp save_transaction(socket, :edit, transaction_params) do
    case Budgets.update_transaction(
           socket.assigns.current_scope,
           socket.assigns.transaction,
           transaction_params
         ) do
      {:ok, transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, transaction)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_transaction(socket, :new, transaction_params) do
    case Budgets.create_transaction(socket.assigns.current_scope, transaction_params) do
      {:ok, transaction} ->
        {:noreply,
         socket
         |> put_flash(:info, "Transaction created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, transaction)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _transaction), do: ~p"/transactions"
  defp return_path(_scope, "show", transaction), do: ~p"/transactions/#{transaction}"
end
