defmodule Multivac.MixProject do
  use Mix.Project

  def project do
    [
      app: :multivac,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Multivac.MultivacLibcluster, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libcluster, "~> 3.3"},
      {:libcluster_postgres, "~> 0.1.0"},
      {:oban, "~> 2.17"}
    ]
  end
end
