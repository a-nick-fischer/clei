defmodule FixedResponse do
  @moduledoc """
  Returns a fixed response.
  """

  @behaviour Plug
  import Plug.Conn

  @impl true
  def init(opts) do
    Keyword.merge(
      [content: "", status: :ok],
      opts
    )
  end

  @impl true
  def call(conn, opts) do
    resp(conn, opts[:status], opts[:content])
  end
end
