defmodule Clei.BuiltinPlugs.HTTPProxy do
  @moduledoc """
  Proxies a HTTP connection.
  """

  @behaviour Plug
  require Logger
  import Plug.Conn
  alias Clei.BuiltinPlugs.Finch, as: ProxyFinch
  alias Plug.Conn.Status

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, opts) do
    result =
      conn
      |> create_request(opts)
      |> Finch.stream(ProxyFinch, conn, &stream_callback/2)

    case result do
      {:ok, conn} ->
        conn

      {:error, error} ->
        Logger.warn("Error while proxying connection: #{inspect(error)}")
        resp(conn, 500, Status.reason_phrase(500))
    end
  end

  defp create_request(conn, opts) do
    Finch.build(
      conn.method,
      Keyword.get(opts, :upstream) <> conn.request_path,
      conn.req_headers,
      {:stream, create_body_input_stream(conn)}
    )
  end

  defp create_body_input_stream(conn) do
    Stream.unfold(read_body(conn), fn
      {:ok, body, _} -> {body, :halt}
      {:more, body, _} -> {body, read_body(conn)}
      :halt -> nil
    end)
  end

  def stream_callback({:status, status}, conn) do
    put_status(conn, status)
  end

  def stream_callback({:headers, headers}, %Plug.Conn{status: status} = conn) do
    Enum.reduce(headers, conn, fn {key, value}, conn ->
      put_resp_header(conn, key, value)
    end)
    # https://hexdocs.pm/plug/Plug.Conn.html#send_chunked/2
    |> send_chunked(status)
  end

  def stream_callback({:data, data}, conn) do
    {:ok, conn} = chunk(conn, data)
    conn
  end
end
