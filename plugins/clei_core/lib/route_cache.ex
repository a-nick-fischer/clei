defmodule Clei.Core.RouteCache do
  @moduledoc """
  Preprocesses and stores routes.

  As routes are not expected to be updated frequently, we're using Discord's
  FastGlobal library to optimize reads, at the cost of very expensive writes.
  """

  alias Clei.Core.Matcher
  alias Clei.Core.Route
  @key_name :routes

  def reload! do
    raw_routes = get_raw()

    raw_routes
    |> Enum.flat_map(&preprocess_route(&1, raw_routes))
    |> Enum.map(&Route.init/1)
    |> put()
  end

  defp put(routes), do: FastGlobal.put(:routes, routes)

  defp preprocess_route({matcher_str, handlers}, routes) when not is_atom(matcher_str) do
    [
      %Route{
        matcher: matcher_str |> Code.string_to_quoted!() |> Macro.expand(Matcher.env()),
        handlers: Enum.flat_map(handlers, &preprocess_handler(&1, routes))
      }
    ]
  end

  defp preprocess_route(_route, _routes), do: []

  defp preprocess_handler(handler, _routes) when is_tuple(handler), do: [handler]

  defp preprocess_handler(handler, routes)
       when is_atom(handler) and is_map_key(routes, handler) do
    routes[handler]
  end

  def get_raw, do: Application.fetch_env!(:clei, @key_name)

  def get, do: FastGlobal.get(@key_name)
end
