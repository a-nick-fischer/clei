FROM clei-builder as builder

RUN mix with_plugins reverse_proxy_plug 2.1 && \
    mix setup && \
    mix release --path /release

FROM clei

COPY --from=builder /release /app