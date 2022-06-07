import Config
alias Clei.BuiltinPlugs, as: C

config :clei,
  routes: %{
    ~s|true| => [
      {Plug.Logger, []},
      {C.FixedResponse, content: "Not Found", status: 404}
    ]
  }
