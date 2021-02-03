defmodule HomeWeb.Router do
  use Phoenix.Router
  import Plug.Conn
  import Phoenix.Controller
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug :fetch_live_flash
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :authenticated do
    plug(HomeWeb.Plugs.AuthPlug)
  end

  scope "/", HomeWeb do
    pipe_through [:browser, :authenticated]

    get("/", HomeController, :index)
  end

  scope "/", HomeWeb do
    pipe_through [:browser]

    get("/login", LoginController, :index)
    post("/login", LoginController, :login)
  end
end
