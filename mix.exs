defmodule Senkosan.MixProject do
  use Mix.Project

  def project do
    [
      app: :senkosan,
      version: "0.0.1",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    if Mix.env() != :test do
      [
        extra_applications: [:logger],
        mod: {Senkosan.Application, []}
      ]
    else
      [extra_applications: [:logger]]
    end
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, "~> 0.4"},
      {:amnesia, "~> 0.2.8"},
      {:meck, "~> 0.9.0", only: :test}
    ]
  end
end
