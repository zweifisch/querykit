ExUnit.start()

Code.require_file("support/test_repo.ex", __DIR__)

# Start the test repo
Application.put_env(:querykit, Querykit.TestRepo,
  database: ":memory:",
  pool: Ecto.Adapters.SQL.Sandbox,
  adapter: Ecto.Adapters.SQLite3
)

{:ok, _} = Application.ensure_all_started(:ecto_sql)
{:ok, _} = Querykit.TestRepo.start_link()

# Configure the database for testing
Ecto.Adapters.SQL.Sandbox.mode(Querykit.TestRepo, :manual)
