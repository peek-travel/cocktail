defmodule Cocktail.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cocktail,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      dialyzer: [ flags: [:unmatched_returns, :error_handling, :underspecs]],

      # Docs
      name: "Cocktail",
      source_url: "https://github.com/peek-travel/cocktail",
      docs: [main: "Cocktail",
            #  logo: "path/to/logo.png",
             extras: ["README.md"]],

      # Coverage
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test]
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
      {:timex, "~> 3.1"},
      {:poison, ">= 2.0.0"},

      {:excoveralls, "~> 0.7", only: :test},

      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:dialyxir, "~> 0.5", only: :dev, runtime: false}
    ]
  end
end
