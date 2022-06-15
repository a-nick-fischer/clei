defmodule Clei.Core.Matcher do
  @moduledoc """
  Provides means to execute `matcher expressions`, e.g. Elixir code fragments, which
  determine if a route should be invoked.
  """

  alias Clei.Core.Route

  def route_matches?(%Route{matcher: matcher}, conn) do
    {result, _} = Code.eval_quoted(matcher, bindings(conn), env())

    result
  end

  def env do
    __ENV__
  end

  def bindings(%Plug.Conn{remote_ip: {a, b, c, d}} = conn) do
    [
      conn: conn,
      host: conn.host,
      method: conn.method,
      path: conn.request_path,
      scheme: conn.scheme,
      cookies: conn.req_cookies,
      headers: conn.req_headers,
      ip: "#{a}.#{b}.#{c}.#{d}"
    ]
  end

  defmacro json do
    quote do
      Plug.Conn.get_req_header(var!(conn), "content-type") === ["application/json"]
    end
  end

  defmacro xml do
    quote do
      type = Plug.Conn.get_req_header(var!(conn), "content-type")
      type === ["application/xml"] or type === ["text/xml"]
    end
  end

  defmacro check_path_and_method(nil, method) do
    quote do
      var!(conn).method === unquote(method)
    end
  end

  defmacro check_path_and_method(path, method) do
    pattern =
      path
      |> Regex.escape()
      |> String.replace("\\*\\*", ".*")
      |> String.replace("\\*", "[^/]*")
      |> Regex.compile!()
      |> Macro.escape()

    quote do
      IO.inspect(unquote(pattern))

      Regex.match?(unquote(pattern), var!(conn).request_path) and
        var!(conn).method === unquote(method)
    end
  end

  defmacro get(path \\ nil) do
    quote do
      check_path_and_method(unquote(path), "GET")
    end
  end

  defmacro post(path \\ nil) do
    quote do
      check_path_and_method(unquote(path), "POST")
    end
  end

  defmacro patch(path \\ nil) do
    quote do
      check_path_and_method(unquote(path), "PATCH")
    end
  end

  defmacro put(path \\ nil) do
    quote do
      check_path_and_method(unquote(path), "PUT")
    end
  end

  defmacro delete(path \\ nil) do
    quote do
      check_path_and_method(unquote(path), "DELETE")
    end
  end

  defmacro head(path \\ nil) do
    quote do
      check_path_and_method(unquote(path), "HEAD")
    end
  end

  defmacro tls do
    quote do
      var!(conn).scheme === :https
    end
  end

  defmacro prefix(path_prefix) do
    quote do
      String.starts_with?(var!(conn).request_path, unquote(path_prefix))
    end
  end

  defmacro header(header) do
    quote do
      Plug.Conn.get_req_header(var!(conn), unquote(header))
    end
  end

  defmacro query_param(param) do
    quote do
      Plug.Conn.fetch_query_params(var!(conn)).query_params[unquote(param)]
    end
  end

  defmacro cookie(cookie) do
    quote do
      Plug.Conn.fetch_cookies(var!(conn)).req_cookies[unquote(cookie)]
    end
  end
end
