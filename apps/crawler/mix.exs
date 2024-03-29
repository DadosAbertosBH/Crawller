defmodule Crawler.MixProject do
  use Mix.Project

  def project do
    version = System.get_env("GITHUB_RUN_NUMBER", "1")

    [
      app: :crawler,
      version: "0.0.0-rc#{version}",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.11",
      description: description(),
      start_permanent: Mix.env() == :prod,
      package: package(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: "https://github.com/DadosAbertosBH/Crawller",
      deps: deps()
    ]
  end

  defp description() do
    "Crawler for dadosabertosdebh"
  end

  defp package() do
    [
      name: "dadosabertosbh_crawler",
      licenses: ["GPL-3.0-or-later"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
                CHANGELOG*),
      licenses: ["GPL-3.0-or-later"],
      links: %{"GitHub" => "https://github.com/DadosAbertosBH/Crawller"}
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
      {:excoveralls, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.24.1", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~>  1.1.0", only: :dev},
      {:benchee, "~> 1.0", only: :dev}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      # {:sibling_app_in_umbrella, in_umbrella: true}
    ]
  end
end
