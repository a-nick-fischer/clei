# Builder stage for building the elixir release
FROM elixir:1.13-alpine as builder

ADD . /app
WORKDIR /app
ENV MIX_ENV=prod

RUN mix do \
        local.hex --if-missing --force, \
        local.rebar --if-missing --force, \
        deps.get, \
        deps.compile, \
        release

# Compressor stage for compressing the bundled erlang runtime
# You may call it premature optimization, I call it "a few MB less" :P
FROM alpine:3.15.4 as compressor

COPY --from=builder /app/_build/prod/rel/clei /app

RUN apk add upx && \
        upx --lzma --best /app/erts-*/bin/* || true

# Final destination image
FROM alpine:3.15.4

COPY --from=compressor /app /app
COPY --from=builder /app/VERSION /app/VERSION

# Create a softlink for the 
RUN ln -s /app/releases/$(cat /app/VERSION)/runtime.exs /config.exs && \
    apk add --no-cache \
        ncurses-libs \
        zlib \
        openssl \
        ca-certificates \
        libgcc \
        libstdc++ && \
        rm -fr /var/cache/apk/*

USER 1000

ENTRYPOINT ["/app/bin/clei", "start"]