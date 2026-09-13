defmodule AlloyWeb.DashboardLive do
  use AlloyWeb, :live_view

  alias Alloy.Accounts
  alias Alloy.Budgets

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>Dashboard</.header>

      <ul>
        <li :for={row <- @summaries}>
          {row.account.name}: income {Alloy.Money.format(row.income)}, expense {Alloy.Money.format(
            row.expense
          )}, net {Alloy.Money.format(row.net)}
        </li>
      </ul>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    scope = socket.assigns.current_scope
    today = Date.utc_today()

    accounts = Accounts.list_accounts(scope)

    summaries =
      Enum.map(accounts, fn account ->
        summary = Budgets.monthly_summary(scope, account.id, today.year, today.month)
        income = summary.income || 0
        expense = summary.expense || 0
        %{account: account, income: income, expense: expense, net: income - expense}
      end)

    {:ok, assign(socket, :summaries, summaries)}
  end
end
