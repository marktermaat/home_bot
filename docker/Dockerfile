# ===== Build phase
FROM elixir:1.12.2-alpine as builder
ENV MIX_ENV=prod

# Install GIT for dependencies straight from git
RUN apk add --no-cache git

# Install gcc to build elixir_
RUN apk add --no-cache make gcc libc-dev

# Copy code
COPY lib ./lib
COPY config ./config
COPY priv ./priv
COPY mix.exs ./mix.exs
COPY mix.lock ./mix.lock
COPY .version ./.version

# Build release
RUN mix local.rebar --force && \
  mix local.hex --force && \
  mix deps.get && \
  mix phx.digest && \
  mix release

# ===== Deployment phase
FROM alpine:3

# Install bash and openssl
RUN apk add --no-cache --update bash openssl libgcc libstdc++ ncurses-libs

# Set environment variables and expose ports
EXPOSE 4001

# Set the working dir
WORKDIR /app

# Copy release
COPY --from=builder _build/prod/rel/home_bot/ .

# Run command
CMD ["/app/bin/home_bot", "start"]