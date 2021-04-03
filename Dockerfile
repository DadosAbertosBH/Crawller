FROM elixir:1.11.4-alpine AS build

# install build dependencies
RUN apk add --no-cache build-base 

# prepare build dir
WORKDIR /app

# install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# set build ENV
ENV MIX_ENV=prod

# install mix dependencies
COPY ./ ./
RUN mix do deps.get, deps.compile

RUN mix do compile, release

# prepare release image
FROM alpine:3.9 AS app
RUN apk add --no-cache openssl ncurses-libs

WORKDIR /app

RUN chown nobody:nobody /app

USER nobody:nobody

COPY --from=build --chown=nobody:nobody /app/_build/prod/rel/crawler ./

ENV HOME=/app

CMD ["bin/crawler", "start"]
FROM elixir:1.9.0-alpine


COPY ./ /app

WORKDIR /app

RUN mix local.hex --force
RUN mix local.rebar --force
ENV MIX_ENV=prod
RUN mix do deps.get, deps.compile
RUN mix do compile, release

COPY apps/crawler/dadosabertosdebh.json /app/dadosabertosdebh.json
ENV GOOGLE_APPLICATION_CREDENTIALS /app/dadosabertosdebh.json

RUN chmod +x /app/_build/prod/rel/crawler/bin/crawler

ENTRYPOINT ["/app/_build/prod/rel/crawler/bin/crawler", "start"]