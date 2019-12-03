defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :myapp,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {MyApp.App, []},
      extra_applications: [:logger, :cowboy, :plug, :poison]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:cowboy, "~> 1.0.0"},
      {:plug, "~> 1.5"},
      {:plug_cowboy, "~> 1.0"},
      {:poison, "~> 3.1"},
      {:myxql, "~> 0.2.0"}
    ]
  end
end
