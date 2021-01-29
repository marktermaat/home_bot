defmodule HomeWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :home_bot

  @session_options [
    store: :cookie,
    key: "ter_maat_session_key",
    signing_salt: System.get_env("HOME_WEB_SIGNING_SALT") || "wJ2D06w5"
  ]

  plug(Plug.Parsers, parsers: [:urlencoded])
  plug(Plug.Session, @session_options)
  plug(HomeWeb.Router)
end
