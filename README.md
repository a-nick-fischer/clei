<p align="center">
  <img src="assets/logo.png" width=200>
</p>

---

<p align="center">
<b>A versatile and lightweight API gateway written in Elixir!</b>
</p>

## Getting Started
Get started by downloading the docker image:

```
docker pull anickfischer/clei
```

Now, let's write an example config to a file named `config.exs` (Clei is configured in Elixir, for now):
```elixir
import Config
alias Clei.BuiltinPlugs, as: C

config :clei,
  server: %{port: 80},

  routes: %{
    :logging => [
      {Plug.Logger, []}
    ],

    ~s|prefix.("/image") and get.()| => [
      :logging,
      {C.HTTPProxy, upstream: "https://httpbin.org/"}
    ],

    ~s|true| => [
      :logging,
      {C.FixedResponse, content: "Not Found", status: 404}
    ]
  }
```

What this does:
- It starts Clei on Port `80`
- Next it creates a new middleware `:logging`, which can be used in other middlewares/routes
- Afterwards it defines a new route, which proxys all `GET` requests to `/image` to `https://httpbin.org/`
- Lastly it defines a catch-all route, which just returns `Not Found`

```
docker run -it -v config.exs:/config.exs -p 80:80 anickfischer/clei
```

Now, open a browser and go to `http://localhost/image/png`

## Do we need another API gateway?

No, probably we don't. Is it a great opportunity to learn and improve my Elixir skills? Definitely😃.