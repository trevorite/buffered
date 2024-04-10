defmodule Buffered.MixProject do
  use Mix.Project

  def project do
    [
      app: :buffered,
      version: "0.4.0",
      elixir: ">= 1.7.0",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: "Buffered queue and counter",
      source_url: "https://github.com/jechol/buffered",
      docs: docs()
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
      {:ex_doc, "~> 0.32.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/jechol/buffered"},
      maintainers: ["Jechol Lee(mr.jechol@gmail.com)"]
    ]
  end

  defp docs() do
    [
      main: "readme",
      name: "buffered",
      canonical: "http://hexdocs.pm/buffered",
      source_url: "https://github.com/jechol/buffered",
      extras: [
        "README.md"
      ]
    ]
  end
end
