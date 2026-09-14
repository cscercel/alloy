defmodule AlloyWeb.AccountLive.Show do
  use AlloyWeb, :live_view

  alias Alloy.Accounts
  alias Alloy.Repo

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

      <h3>Members</h3>
      <ul>
        <li :for={user <- @account.users}>{user.email}</li>
      </ul>

      <h3>Add a member</h3>
      <.form for={@member_form} id="add-member-form" phx-submit="add_member">
        <.input field={@member_form[:email]} type="text" label="Email" />
        <.button phx-disable-with="Adding...">Add</.button>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Accounts.subscribe_accounts(socket.assigns.current_scope)
    end

    account =
      socket.assigns.current_scope
      |> Accounts.get_account!(id)
      |> Repo.preload(:users)

    {:ok,
     socket
     |> assign(:page_title, "Show Account")
     |> assign(:account, account)
     |> assign(:member_form, to_form(%{"email" => ""}))}
  end

  @impl true
  def handle_event("add_member", %{"email" => email}, socket) do
    case Accounts.add_member(socket.assigns.current_scope, socket.assigns.account, email) do
      {:ok, _account_user} ->
        account = Repo.preload(socket.assigns.account, :users, force: true)

        {:noreply,
         socket
         |> put_flash(:info, "Member added successfully")
         |> assign(:account, account)
         |> assign(:member_form, to_form(%{"email" => ""}))}

      {:error, :user_not_found} ->
        {:noreply, put_flash(socket, :error, "No user found with that email")}

      {:error, %Ecto.Changeset{}} ->
        {:noreply, put_flash(socket, :error, "That user is already a member")}
    end
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
