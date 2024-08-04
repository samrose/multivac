defmodule Multivac.MixProject do
  use Mix.Project

  def project do
    [
      app: :multivac,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :runtime_tools],
      mod: {Multivac.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.6"},
      {:postgrex, ">= 0.0.0"},
      {:oban, "~> 2.18"},
      {:jason, "~> 1.2"}
    ]
  end
end
