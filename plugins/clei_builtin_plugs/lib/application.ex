defmodule Clei.BuiltinPlugs.Application do
  @moduledoc """
  Supervisor for applications needed by plugins included in clei 
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch, name: Clei.BuiltinPlugs.Finch}
    ]

    opts = [strategy: :one_for_one, name: Clei.BuiltinPlugs.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
