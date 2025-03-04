defmodule Request.MixProject do
  use Mix.Project

  def project do
    [
      app: :request,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
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
      {:hound, "~> 1.1"},
      {:httpoison, "~> 2.0"},
      {:floki, "~> 0.34.0"},
      {:csv, "~> 2.4"},
      {:html_entities, "~> 0.5.2"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
