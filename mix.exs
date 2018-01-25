defmodule Cocktail.Mixfile do
  use Mix.Project

  @version "0.7.0"

  def project do
    [
      app: :cocktail,
      name: "Cocktail",
      source_url: "https://github.com/peek-travel/cocktail",
      version: @version,
      elixir: "~> 1.5",
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      dialyzer: [flags: [:unmatched_returns, :error_handling, :underspecs]],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.json": :test
      ]
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp description do
    """
    Cocktail is a date/time recurrence library for Elixir based on iCalendar events.
    It can generate a stream of dates/times based on a set of repeat rules.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README.md", "LICENSE.md"],
      maintainers: ["Chris Dosé"],
      licenses: ["MIT"],
      links: %{GitHub: "https://github.com/peek-travel/cocktail"}
    ]
  end

  defp docs do
    [
      main: "Cocktail.Schedule",
      logo: "logo.png",
      source_ref: @version,
      source_url: "https://github.com/peek-travel/cocktail",
      extras: ["README.md", "LICENSE.md"]
    ]
  end

  defp deps do
    [
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.16", only: :dev, runtime: false},
      {:ex_unit_notifier, "~> 0.1", only: :test},
      {:excoveralls, "~> 0.7", only: :test},
      {:inch_ex, ">= 0.0.0", only: :docs},
      {:mix_test_watch, "~> 0.3", only: :dev, runtime: false},
      {:poison, ">= 2.0.0"},
      {:timex, "~> 3.1"}
    ]
  end
end
