defmodule Querykit.TestRepo do
  use Ecto.Repo,
    otp_app: :querykit,
    adapter: Ecto.Adapters.SQLite3
end
