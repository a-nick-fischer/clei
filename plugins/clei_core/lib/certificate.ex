defmodule Clei.Core.Certificate do
  @moduledoc """
  Generates and manages TLS certificates
  """

  alias X509.Certificate.Extension

  def self_signed(sans, opts \\ []) do
    cn = Keyword.get(opts, :cn, "Clei Self-Signed")
    alg = Keyword.get(opts, :alg, :secp256r1)

    priv_key =
      if alg == :rsa do
        key_length = Keyword.get(opts, :key_length, 4096)
        X509.PrivateKey.new_rsa(key_length)
      else
        X509.PrivateKey.new_ec(alg)
      end

    cert =
      X509.Certificate.self_signed(
        priv_key,
        "CN=#{cn}",
        extensions: [subject_alt_name: Extension.subject_alt_name(sans)]
      )

    {priv_key, cert}
  end

  def to_der({priv_key, cert}) do
    alg =
      case X509.Certificate.public_key(cert) do
        {:RSAPublicKey, _, _} -> :RSAPrivateKey
        {{:ECPoint, _}, _} -> :ECPrivateKey
      end

    {
      {alg, X509.PrivateKey.to_der(priv_key)},
      X509.Certificate.to_der(cert)
    }
  end
end
