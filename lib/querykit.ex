defmodule Querykit do
  @moduledoc """
  Querykit provides SQL string interpolation with automatic parameter binding.

  This module offers a convenient way to write SQL queries with Elixir expressions
  that are automatically converted to parameterized queries, helping prevent SQL
  injection and making the code more maintainable.
  """

  @doc ~S"""
  SQL sigil (~q).

  Interpolates Elixir expressions into a SQL string, replacing them with
  positional parameters ($1, $2, etc.) and returning a tuple containing the
  parameterized SQL string and a list of the interpolated values.

  ## Parameters

  The sigil accepts any Elixir expression inside #{} interpolation syntax.
  These expressions are replaced with positional parameters ($1, $2, etc.)
  in the resulting SQL string.

  ## Return Value

  Returns a tuple `{sql_string, params}` where:
  - `sql_string` is the SQL query with $n placeholders
  - `params` is a list of values to be bound to the placeholders

  ## Examples

      iex> import Querykit
      iex> name = "Alice"
      iex> ~q"SELECT * FROM users WHERE name = #{name}"
      {"SELECT * FROM users WHERE name = $1", ["Alice"]}

  """
  defmacro sigil_q({:<<>>, _meta, parts}, _modifiers) do
    {sql, args} =
      Enum.reduce(parts, {"", []}, fn
        binary, {sql, args} when is_binary(binary) ->
          {sql <> binary, args}

        {:"::", _, [{{:., _, _}, _, [expr]}, {:binary, _, _}]}, {sql, args} ->
          {sql <> "$#{length(args) + 1}", args ++ [expr]}
      end)

    quote do
      {unquote(sql), unquote(args)}
    end
  end
end
