defmodule PoolProj.MixProject do
  use Mix.Project

  def project do
    [
      app: :pool_proj,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
	mod: {PoolProj.Application, []},
	extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}

      # Dep for getting location data from CSV
      {:nimble_csv, "~> 1.2"},

      # Deps for database
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},

      # For decoding location map/string
      {:jason, "~> 1.4"},

      # For Sending SMS
      {:ex_twilio, "~> 0.8.0"}
    ]
  end
end
