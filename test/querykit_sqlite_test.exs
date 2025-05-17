defmodule QuerykitSQLiteTest do
  use ExUnit.Case

  import Querykit
  alias Exqlite.Sqlite3, as: SQLite

  setup do
    {:ok, conn} = SQLite.open(":memory:")

    :ok =
      SQLite.execute(conn, """
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        age INTEGER,
        active BOOLEAN DEFAULT true
      )
      """)

    :ok =
      SQLite.execute(conn, """
      INSERT INTO users (name, age, active) VALUES
      ('Alice', 25, true),
      ('Bob', 30, true),
      ('Charlie', 35, false)
      """)

    on_exit(fn -> SQLite.close(conn) end)
    {:ok, conn: conn}
  end

  def fetch_all(conn, statement) do
    case SQLite.step(conn, statement) do
      {:row, row} ->
        [row | fetch_all(conn, statement)]

      :done ->
        []
    end
  end

  def execute(conn, {sql, params}) do
    {:ok, statement} = SQLite.prepare(conn, sql)
    :ok = SQLite.bind(statement, params)
    fetch_all(conn, statement)
  end

  test "execute select query with parameter", %{conn: conn} do
    assert [["Bob"], ["Charlie"]] == execute(conn, ~q(SELECT name FROM users WHERE age > #{25}))
  end

  test "execute insert with parameters", %{conn: conn} do
    name = "David"
    age = 40
    assert [] = execute(conn, ~q"INSERT INTO users (name, age) VALUES (#{name}, #{age})")
    assert [["David", 40]] == execute(conn, ~q"SELECT name, age FROM users WHERE name = #{name}")
  end

  test "execute update with multiple parameters", %{conn: conn} do
    assert [] = execute(conn, ~q(UPDATE users SET active = #{0} WHERE age < #{30}))
    assert [[2]] = execute(conn, ~q"SELECT COUNT(*) FROM users WHERE active = false")
  end

  test "execute delete with parameters", %{conn: conn} do
    assert [] = execute(conn, ~q(DELETE FROM users WHERE age > #{30}))
    assert [[2]] = execute(conn, ~q"SELECT COUNT(*) FROM users")
  end
end
