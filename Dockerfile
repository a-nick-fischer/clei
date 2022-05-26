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

FROM alpine:3.15.4 as compressor

COPY --from=builder /app/_build/prod/rel/clei /app

RUN apk add upx && \
        upx --lzma --best /app/erts-*/bin/* || true

FROM alpine:3.15.4 

COPY --from=compressor /app /app

RUN apk add --no-cache \
      ncurses-libs \
      zlib \
      openssl \
      ca-certificates \
      libgcc \
      libstdc++ && \
      rm -fr /var/cache/apk/*

ENTRYPOINT ["/app/bin/clei", "start"]