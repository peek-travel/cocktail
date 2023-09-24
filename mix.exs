defmodule Cocktail.Mixfile do
  use Mix.Project

  @version "0.10.3"

  def project do
    [
      app: :cocktail,
      name: "Cocktail",
      source_url: "https://github.com/peek-travel/cocktail",
      version: @version,
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      deps: deps(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: dialyzer(),
      preferred_cli_env: preferred_cli_env()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

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
      maintainers: ["Jesse Van Volkinburg", "Chris Dosé"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/peek-travel/cocktail",
        "Readme" => "https://github.com/peek-travel/cocktail/blob/#{@version}/README.md",
        "Changelog" => "https://github.com/peek-travel/cocktail/blob/#{@version}/CHANGELOG.md"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      logo: "logo.png",
      source_ref: @version,
      source_url: "https://github.com/peek-travel/cocktail",
      extras: ["README.md", "LICENSE.md", "CHANGELOG.md"]
    ]
  end

  defp dialyzer do
    [
      plt_core_path: "_build/#{Mix.env()}"
    ]
  end

  defp preferred_cli_env do
    [
      coveralls: :test,
      "coveralls.detail": :test,
      "coveralls.post": :test,
      "coveralls.html": :test,
      "coveralls.json": :test
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.23", only: :dev, runtime: false},
      {:excoveralls, "~> 0.10", only: :test},
      {:tzdata, "~> 1.1"}
    ]
  end
end
