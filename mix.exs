defmodule Querykit.MixProject do
  use Mix.Project

  def project do
    [
      name: "Querykit",
      app: :querykit,
      version: "0.2.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:ecto_sql, "~> 3.10", only: :test},
      {:ecto_sqlite3, "~> 0.10", only: :test}
    ]
  end

  defp description() do
    """
    A lightweight Elixir library that provides safe SQL query interpolation through a convenient sigil-based syntax.
    Automatically handles parameter binding to help prevent SQL injection while maintaining readable query syntax.
    """
  end

  defp package() do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/zweifisch/querykit"
      }
    ]
  end
end
