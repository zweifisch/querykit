import Config

config :querykit, Querykit.TestRepo,
  database: ":memory:",
  pool: Ecto.Adapters.SQL.Sandbox,
  adapter: Ecto.Adapters.SQLite3

config :querykit, ecto_repos: [Querykit.TestRepo]
