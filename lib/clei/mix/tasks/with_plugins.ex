defmodule Mix.Tasks.WithPlugins do
  @moduledoc """
  Mix task for adding plugins. They have to be installed using `mix setup` afterwards.

  Example usage:
  ```elixir
  mix with_plugins reverse_proxy_plug 2.1, jason 1.3
  ```
  """

  @shortdoc "Installs dependencies from the commandline."

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    dependencies =
      args
      |> Enum.chunk_every(2)
      |> Enum.map(fn [k, v] -> {String.to_atom(k), "~> #{v}"} end)
      |> inspect()

    File.write!("plugins.exs", dependencies)
  end
end
