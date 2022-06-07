defmodule Clei.Application do
  @moduledoc """
  Entrypoint of the application. Starts the apps' supervisor tree.
  """

  use Application

  alias Clei.Core.Certificate
  alias Clei.Core.Entry

  @extra_keys [:http_port, :https_port]

  @impl true
  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Entry, options: http_cowboy_opts()},
      {Plug.Cowboy, scheme: :https, plug: Entry, options: https_cowboy_opts()},
      {Plug.Cowboy.Drainer, refs: [Entry.HTTP, Entry.HTTPS]}
    ]

    IO.puts(banner())

    opts = [strategy: :one_for_one, name: Clei.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp http_cowboy_opts do
    opts = Application.fetch_env!(:clei, :server)
    port = Map.fetch!(opts, :http_port)

    opts
    |> Map.put(:port, port)
    |> Map.drop(@extra_keys)
    |> Enum.into([])
  end

  defp https_cowboy_opts do
    opts = Application.fetch_env!(:clei, :server)
    port = Map.fetch!(opts, :https_port)

    tls_key_given = Map.has_key?(opts, :keyfile) or Map.has_key?(opts, :key)
    opts = if tls_key_given do
      opts
    else
      {key, cert} = Certificate.self_signed(["localhost"]) |> Certificate.to_der()

      opts
      |> Map.put(:key, {:ECPrivateKey, key})
      |> Map.put(:cert, cert)
    end

    opts
    |> Map.put(:port, port)
    |> Map.drop(@extra_keys)
    |> Enum.into([])
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
