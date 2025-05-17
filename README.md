# Querykit

Querykit is a lightweight Elixir library that provides safe SQL query interpolation through a convenient sigil-based syntax. It automatically handles parameter binding to help prevent SQL injection while maintaining readable query syntax.

## Installation

Add `querykit` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:querykit, "~> 0.1.0"}
  ]
end
```

## Usage

Import Querykit in your module:

```elixir
import Querykit
 ```

Query with a single parameter:

```elixir
~q(SELECT * FROM users WHERE id = #{id})
# {"SELECT * FROM users WHERE id = $1", [id]}
```