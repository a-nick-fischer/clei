defmodule Clei.MixProject do
  use Mix.Project

  def project do
    [
      app: :clei,
      version: File.read!("VERSION"),
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Clei.Application, []}
    ]
  end

  defp deps do
    external_plugins() ++
    local_plugins() ++
      [
        {:plug_cowboy, "~> 2.5"},
        {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
      ]
  end

  def local_plugins do
    Path.wildcard("plugins/*")
    |> Enum.map(fn dir -> {Path.basename(dir) |> String.to_atom(), path: dir} end)
  end

  def external_plugins do
    {deps, _} = Code.eval_file("plugins.exs")
    deps
  end

  def releases do
    [
      clei: [
        include_executables_for: [:unix],
        applications: [clei: :permanent]
      ]
    ]
  end
end
