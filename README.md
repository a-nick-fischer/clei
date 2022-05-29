<p align="center">
  <img src="assets/logo.png" width=200>
</p>

---

<p align="center">
<b>A versatile and lightweight API gateway written in Elixir!</b>
</p>

## Example Config

```elixir
config :clei,
  server: %{port: 80},

  routes: %{
    :logging => [
      {Plug.Logger, []}
    ],

    ~s|prefix.("/api") and get.() and json.()| => [
      :logging,
      {C.FixedResponse, [content: "Hello, World!"]}
    ],

    ~s|true| => [
      :logging,
      {C.FixedResponse, [content: "Not Found", status: 404]}
    ]
  }
```
(Yes, we're not proxying in this example - WIP)

## Do we need another API gateway?
No, probably we don't. Is it a great opportunity to learn and improve my Elixir skills? Definitely😃.