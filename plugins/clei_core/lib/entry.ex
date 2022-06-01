defmodule Clei.Core.Entry do
  @moduledoc """
  Central plug handling all incoming connections.
  """

  import Plug.Conn
  alias Clei.Core.Matcher
  alias Clei.Core.Route
  alias Clei.Core.RouteCache
  alias Plug.Conn.Status
  require Logger

  def init(_), do: RouteCache.reload!()

  def call(conn, _opts) do
    RouteCache.get()
    |> Enum.find(&Matcher.route_matches?(&1, conn))
    |> handle_route(conn)
  end

  defp handle_route(route, conn) when not is_nil(route) do
    response = Route.call(route, conn)

    case response do
      %Plug.Conn{state: :unset} ->
        Logger.warn("Route did not produce a sendable response: #{inspect(response)}")
        error_resp(conn, :internal_server_error)

      %Plug.Conn{} ->
        response

      _ ->
        Logger.warn("Route produced invalid result: #{inspect(response)}")
        error_resp(conn, :internal_server_error)
    end
  end

  defp handle_route(_route, conn) do
    Logger.warn(
      "No explicit default route defined, using built-in mechanism. Please consider specifying a default route."
    )

    error_resp(conn, :not_found)
  end

  defp error_resp(conn, status) do
    phrase =
      status
      |> Status.code()
      |> Status.reason_phrase()

    resp(conn, status, phrase)
  end
end
