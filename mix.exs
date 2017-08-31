defmodule Cocktail.Mixfile do
  use Mix.Project

  def project do
    [
      app: :cocktail,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),

      # Docs
      name: "Cocktail",
      source_url: "https://github.com/peek-travel/cocktail",
      docs: [main: "Cocktail",
            #  logo: "path/to/logo.png",
             extras: ["README.md"]]
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
      {:ex_doc, "~> 0.16", only: :dev, runtime: false}
    ]
  end
end
