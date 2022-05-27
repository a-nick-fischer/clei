defmodule Clei.Application do
  @moduledoc """
  Entrypoint of the application. Starts the apps' supervisor tree.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: {Clei.Core.Entry, []}, options: cowboy_opts()}
    ]

    IO.puts(banner())

    opts = [strategy: :one_for_one, name: Clei.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # https://hexdocs.pm/plug/1.6.3/Plug.Adapters.Cowboy2.html
  defp cowboy_opts do
    Keyword.merge(
      [port: 80],
      Application.fetch_env!(:clei, :server) |> Enum.into([])
    )
  end

  defp banner do
    banner = ~S"""
      -------------------------------
      _______              ________    
     /         |          |           |
    |          |          |           |
    |          |          |--------   |
    |          |          |           |
     \_______  |________  |________   |
      -------------------------------
    """

    IO.ANSI.format([:cyan, banner])
  end
end
