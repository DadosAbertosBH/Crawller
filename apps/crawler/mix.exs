defmodule Crawler.MixProject do
  use Mix.Project

  def project do
    [
      app: :crawler,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Crawler.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:csv, "~> 2.4.1"},
      {:cachex, "~> 3.3"},
      {:google_api_big_query, "~> 0.59.0"},
      {:goth, "~> 1.3.0-rc.0"},
      {:timex, "~> 3.0"},
      {:geo, "~> 3.0"},
      {:bypass, "~> 2.1", only: :test},
      {:assertions, "~> 0.18.1", only: :test},
      {:ex_doc, "~> 0.24.1", only: :dev, runtime: false},
      {:dialyxir, "~> 0.4", only: [:dev]}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
    ]
  end
end
