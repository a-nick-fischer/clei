import Config

# Just an example config used for testing - will be moved to an example section later

config :clei,
  server: %{
    port: 80
  },
  routes: %{
    ~s|true| => [
      {Plug.Logger, []},
      {FixedResponse, [content: "Not Found!", status: 404]}
    ]
  }
