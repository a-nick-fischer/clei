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
      prepare_headers(conn),
      {:stream, create_body_input_stream(conn)}
    )
  end

  # Partly copied from
  # https://github.com/tallarium/reverse_proxy_plug/blob/4d8bc8ef680744e979fdefb975b25ab282d1ccd1/lib/reverse_proxy_plug.ex#L267
  defp prepare_headers(conn) do
    conn.req_headers
    |> downcase_headers()
    |> remove_hop_by_hop_headers()
    |> add_forward_headers(conn)
  end

  defp downcase_headers(headers) do
    Enum.map(headers, fn {header, value} -> { String.downcase(header), value } end)
  end

  defp remove_hop_by_hop_headers(headers) do
    hop_by_hop_headers = [
      "te",
      "transfer-encoding",
      "trailer",
      "connection",
      "keep-alive",
      "proxy-authenticate",
      "proxy-authorization",
      "upgrade"
    ]

    Enum.reject(headers, fn {header, _} -> Enum.member?(hop_by_hop_headers, header) end)
  end

  defp add_forward_headers(prev_headers, conn) do
    %Plug.Conn{
      scheme: scheme,
      port: port,
      remote_ip: remote_ip,
      host: host
    } = conn


    headers = Enum.into(prev_headers, %{})
    remote_ip_str = remote_ip |> Tuple.to_list() |> Enum.join(".")
    protocol_str = Atom.to_string(scheme)
    port_str = Integer.to_string(port)
    protocol_version = conn
      |> get_http_protocol()
      |> Atom.to_string()

    # TODO: Add IPv6 support: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Forwarded
    forwarded_header = "for=#{remote_ip_str};host=#{host};proto=#{protocol_str}"
    via_header = "#{protocol_version} clei"

    headers
    |> Map.update("via", via_header, fn previous -> "#{previous}, #{via_header}" end)
    |> Map.update("forwarded", forwarded_header, fn previous -> "#{previous}, #{forwarded_header}" end)
    |> Map.update("x-forwarded-for", remote_ip_str, fn previous -> "#{previous}, #{remote_ip_str}" end)
    |> Map.put_new("x-forwarded-proto", protocol_str)
    |> Map.put_new("x-forwarded-port", port_str)
    |> Enum.into([])
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
