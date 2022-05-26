defmodule Debug do
  @moduledoc """
  Logs the internal representation of current connection. For debug
  purposes only.
  """

  require Logger
  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    Logger.debug(inspect(conn))
    conn
  end
end
