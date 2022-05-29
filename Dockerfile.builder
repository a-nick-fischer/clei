FROM elixir:1.13-alpine

LABEL maintainer="Nick Fischer <nick.korotkin@outlook.com>"

ADD . /app
WORKDIR /app
ENV MIX_ENV=prod

# Partially precompile the image
RUN mix setup