defmodule Alloy.Repo do
  use Ecto.Repo,
    otp_app: :alloy,
    adapter: Ecto.Adapters.SQLite3
end
