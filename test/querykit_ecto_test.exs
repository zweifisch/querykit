defmodule QuerykitEctoTest do
  use ExUnit.Case

  import Querykit
  import Ecto.Changeset
  alias Querykit.TestRepo

  defmodule User do
    use Ecto.Schema

    schema "users" do
      field(:name, :string)
      field(:age, :integer)
      field(:active, :boolean, default: true)
      timestamps()
    end
  end

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
    Ecto.Adapters.SQL.Sandbox.mode(TestRepo, {:shared, self()})

    TestRepo.query!("""
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      age INTEGER,
      active BOOLEAN DEFAULT true,
      inserted_at TIMESTAMP,
      updated_at TIMESTAMP
    )
    """)
    :ok
  end

  test "q sigil with Ecto.Query" do
    assert ~q"SELECT * FROM #{User} WHERE age > #{25} AND active = #{1}" ==
             {"SELECT * FROM users WHERE age > $1 AND active = $2", [25, 1]}
  end

  test "q sigil with Ecto changeset" do
    params = %{"name" => "Alice", "age" => 25}
    changeset = cast(%User{}, params, [:name, :age])

    assert ~q"INSERT INTO #{User} (name, age) VALUES (#{get_change(changeset, :name)}, #{get_change(changeset, :age)})" ==
             {"INSERT INTO users (name, age) VALUES ($1, $2)", ["Alice", 25]}
  end

  test "execute query against SQLite" do
    {query, params} = ~q"INSERT INTO #{User} (name, age) VALUES (#{"Bob"}, #{30})"
    {:ok, _} = TestRepo.query(query, params)

    {select_query, select_params} = ~q"SELECT name, age FROM #{User} WHERE age > #{25}"
    assert {:ok, %{rows: [["Bob", 30]]}} = TestRepo.query(select_query, select_params)
  end

  test "execute multiple operations" do
    Enum.each([
      {"Alice", 25},
      {"Bob", 30},
      {"Charlie", 35}
    ], fn {name, age} ->
      {query, params} = ~q"INSERT INTO #{User} (name, age) VALUES (#{name}, #{age})"
      {:ok, _} = TestRepo.query(query, params)
    end)

    {update_query, update_params} = ~q"UPDATE #{User} SET active = #{0} WHERE age > #{30}"
    {:ok, _} = TestRepo.query(update_query, update_params)

    {select_query, select_params} = ~q"SELECT name FROM #{User} WHERE active = #{0}"
    {:ok, %{rows: rows}} = TestRepo.query(select_query, select_params)
    assert rows == [["Charlie"]]
  end
end
