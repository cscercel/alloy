defmodule AlloyWeb.TransferLive.New do
  use AlloyWeb, :live_view

  alias Alloy.{Accounts, Budgets, Money}

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>New Transfer</.header>

      <.form for={@form} id="transfer-form" phx-submit="save">
        <.input
          field={@form[:source_account_id]}
          type="select"
          label="From"
          options={Enum.map(@accounts, &{&1.name, &1.id})}
        />
        <.input
          field={@form[:destination_account_id]}
          type="select"
          label="To"
          options={Enum.map(@accounts, &{&1.name, &1.id})}
        />
        <.input field={@form[:amount]} type="text" label="Amount" />
        <.input field={@form[:description]} type="text" label="Description" />
        <.input field={@form[:date]} type="date" label="Date" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Transfer</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    accounts = Accounts.list_accounts(scope)

    form =
      to_form(%{
        "source_account_id" => nil,
        "destination_account_id" => nil,
        "amount" => "",
        "description" => "",
        "date" => Date.utc_today()
      })

    {:ok,
     socket
     |> assign(:accounts, accounts)
     |> assign(:form, form)}
  end

  @impl true
  def handle_event("save", params, socket) do
    source_id = String.to_integer(params["source_account_id"])
    source_account = Enum.find(socket.assigns.accounts, fn account -> account.id == source_id end)

    destination_id = String.to_integer(params["destination_account_id"])

    destination_account =
      Enum.find(socket.assigns.accounts, fn account -> account.id == destination_id end)

    date = Date.from_iso8601!(params["date"])

    case Budgets.create_transfer(
           socket.assigns.current_scope,
           Money.parse(params["amount"]),
           source_account,
           destination_account,
           params["description"],
           date
         ) do
      {:ok, _transactions} ->
        {:noreply,
         socket |> put_flash(:info, "Transfer completed") |> push_navigate(to: ~p"/transactions")}

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Transfer failed")}
    end
  end
end
