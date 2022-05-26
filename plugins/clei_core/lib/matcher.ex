defmodule Clei.Core.Matcher do
  @moduledoc """
  Provides means to execute `matcher expressions`, e.g. Elixir code fragments, which
  determine if a route should be invoked.
  """

  alias Clei.Core.Route

  def route_matches?(%Route{matcher: matcher}, conn) do
    bindings =
      Keyword.merge(
        connection_vars(conn),
        helper_funcs(conn)
      )

    {result, _} = Code.eval_string(matcher, bindings, __ENV__)

    result
  end

  defp connection_vars(%Plug.Conn{remote_ip: {a, b, c, d}} = conn) do
    [
      host: conn.host,
      method: conn.method,
      path: conn.request_path,
      scheme: conn.scheme,
      cookies: conn.req_cookies,
      headers: conn.req_headers,
      ip: "#{a}.#{b}.#{c}.#{d}"
    ]
  end

  defp helper_funcs(conn) do
    [
      json: fn ->
        Plug.Conn.get_req_header(conn, "content-type") === ["application/json"]
      end,
      xml: fn ->
        type = Plug.Conn.get_req_header(conn, "content-type")
        type === ["application/xml"] or type === ["text/xml"]
      end,
      get: fn ->
        conn.method === "GET"
      end,
      post: fn ->
        conn.method === "POST"
      end,
      patch: fn ->
        conn.method === "PATCH"
      end,
      put: fn ->
        conn.method === "PUT"
      end,
      delete: fn ->
        conn.method === "DELETE"
      end,
      head: fn ->
        conn.method === "HEAD"
      end,
      tls: fn ->
        conn.scheme === "https"
      end,
      prefix: fn path_prefix ->
        String.starts_with?(conn.request_path, path_prefix)
      end,
      header: fn header ->
        Plug.Conn.get_req_header(conn, header)
      end,
      query_param: fn param ->
        Plug.Conn.fetch_query_params(conn).query_params[param]
      end,
      cookie: fn cookie ->
        Plug.Conn.fetch_cookies(conn).req_cookies[cookie]
      end,
      http_version: fn ->
        Plug.Conn.get_http_protocol(conn)
      end
    ]
  end
end
