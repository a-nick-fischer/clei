defmodule Clei.Core.Route do
  @moduledoc """
  Represents a route, with a `matching expression` and a list of
  handlers. A route can be called to invoke the handlers
  """

  alias Clei.Core.Route

  @enforce_keys [:matcher, :handlers]
  defstruct matcher: "false", handlers: []

  def init(%Route{handlers: handlers} = route) do
    %Route{
      route
      | handlers: Enum.map(handlers, fn {module, args} -> {module, module.init(args)} end)
    }
  end

  def call(%Route{handlers: handlers}, conn) do
    Enum.reduce_while(handlers, conn, fn {module, args}, conn ->
      case resp = module.call(conn, args) do
        %Plug.Conn{halted: true} -> {:halt, resp}
        _ -> {:cont, resp}
      end
    end)
  end
end
