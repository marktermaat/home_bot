defmodule HomeWeb.Endpoint do
  use Phoenix.Endpoint,
    otp_app: :home_bot

  @session_options [
    store: :cookie,
    key: "ter_maat_session_key",
    signing_salt: System.get_env("HOME_WEB_SIGNING_SALT") || "wJ2D06w5"
  ]

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/",
    from: :home_bot,
    gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.CodeReloader
    plug Phoenix.LiveReloader
  end

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Plug.Session, @session_options)
  plug(HomeWeb.Router)
end
