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

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :authenticated do
    plug(HomeWeb.Plugs.AuthPlug)
  end

  scope "/", HomeWeb do
    pipe_through [:browser, :authenticated]

    get("/", HomeController, :index)
  end

  scope "/api", HomeWeb do
    pipe_through [:api]

    get("/hourly_gas_usage", EnergyController, :hourly_gas_usage)
    get("/daily_gas_usage", EnergyController, :daily_gas_usage)
    get("/daily_gas_and_temp", EnergyController, :daily_gas_and_temp)
  end

  scope "/", HomeWeb do
    pipe_through [:browser]

    get("/login", LoginController, :index)
    post("/login", LoginController, :login)
  end
end
