defmodule Clei.BuiltinPlugs.RewritePath do
  @moduledoc """
  Rewrites the request path based on a regex.
  """

  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{request_path: path} = conn, opts) do
    path = Regex.replace(opts[:pattern], path, opts[:replacement])

    path_info = String.split(path, "/", trim: true)

    %Plug.Conn{conn | path_info: path_info, request_path: path}
  end
end
