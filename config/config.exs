import Config

# Just an example config used for testing - will be moved to an example section later

config :clei,
  server: %{
    port: 80
  },
  routes: %{
    :default => [
      {Plug.Logger, []}
    ],
    ~s|prefix.("/api") and get.() and json.()| => [
      :default,
      {FixedResponse, [content: "Hello, World!"]}
    ],
    ~s|true| => [
      :default,
      {FixedResponse, [content: "Not Found", status: 404]}
    ]
  }
