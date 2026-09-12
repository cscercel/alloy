defmodule AlloyWeb.TransactionLive.Index do
  use AlloyWeb, :live_view

  alias Alloy.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Transactions
        <:actions>
          <.button variant="primary" navigate={~p"/transactions/new"}>
            <.icon name="hero-plus" /> New Transaction
          </.button>
        </:actions>
      </.header>

      <.table
        id="transactions"
        rows={@streams.transactions}
        row_click={fn {_id, transaction} -> JS.navigate(~p"/transactions/#{transaction}") end}
      >
        <:col :let={{_id, transaction}} label="Amount">{transaction.amount}</:col>
        <:col :let={{_id, transaction}} label="Description">{transaction.description}</:col>
        <:col :let={{_id, transaction}} label="Date">{transaction.date}</:col>
        <:col :let={{_id, transaction}} label="Type">{transaction.type}</:col>
        <:action :let={{_id, transaction}}>
          <div class="sr-only">
            <.link navigate={~p"/transactions/#{transaction}"}>Show</.link>
          </div>
          <.link navigate={~p"/transactions/#{transaction}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, transaction}}>
          <.link
            phx-click={JS.push("delete", value: %{id: transaction.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Budgets.subscribe_transactions(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Transactions")
     |> stream(:transactions, list_transactions(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    transaction = Budgets.get_transaction!(socket.assigns.current_scope, id)
    {:ok, _} = Budgets.delete_transaction(socket.assigns.current_scope, transaction)

    {:noreply, stream_delete(socket, :transactions, transaction)}
  end

  @impl true
  def handle_info({type, %Alloy.Budgets.Transaction{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :transactions, list_transactions(socket.assigns.current_scope), reset: true)}
  end

  defp list_transactions(current_scope) do
    Budgets.list_transactions(current_scope)
  end
end
