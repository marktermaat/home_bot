defmodule Finance.Repo do
  use Ecto.Repo,
    otp_app: :home_bot,
    adapter: Ecto.Adapters.SQLite3
end
