defmodule Clei.Builtin.MixProject do
  use Mix.Project

  def project do
    [
      app: :clei_builtin_plugs,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      # https://github.com/potatosalad/erlang-jose
      {:plug, "~> 1.13"},
      {:clei_core, path: "../clei_core"}
    ]
  end
end
