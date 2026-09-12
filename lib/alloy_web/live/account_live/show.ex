defmodule AlloyWeb.AccountLive.Show do
  use AlloyWeb, :live_view

  alias Alloy.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Account {@account.id}
        <:subtitle>This is a account record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/accounts"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/accounts/#{@account}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit account
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@account.name}</:item>
        <:item title="Type">{@account.type}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe_accounts(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Account")
     |> assign(:account, Accounts.get_account!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Alloy.Accounts.Account{id: id} = account},
        %{assigns: %{account: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :account, account)}
  end

  def handle_info(
        {:deleted, %Alloy.Accounts.Account{id: id}},
        %{assigns: %{account: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current account was deleted.")
     |> push_navigate(to: ~p"/accounts")}
  end

  def handle_info({type, %Alloy.Accounts.Account{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
