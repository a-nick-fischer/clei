FROM elixir:1.13-alpine

ADD . /app
WORKDIR /app
ENV MIX_ENV=prod
