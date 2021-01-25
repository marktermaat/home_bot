# ===== Build phase
FROM elixir:1.11-alpine as builder
ENV MIX_ENV=prod

# Install GIT for dependencies straight from git
RUN apk add --no-cache git

# Copy code
COPY lib ./lib
COPY config ./config
COPY test ./test
COPY mix.exs ./mix.exs
COPY mix.lock ./mix.lock

# Build release
RUN mix local.rebar --force && \
  mix local.hex --force && \
  mix deps.get && \
  mix release

# ===== Deployment phase
FROM alpine:3

# Install bash and openssl
RUN apk add --no-cache --update bash openssl

# Set environment variables and expose ports
EXPOSE 4000

# Set the working dir
WORKDIR /app

# Copy release
COPY --from=builder _build/prod/rel/home_bot/ .

# Run command
CMD ["/app/bin/home_bot", "start"]