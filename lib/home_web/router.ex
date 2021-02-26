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
    get("/energy/gas", EnergyController, :gas)
    get("/energy/electricity", EnergyController, :electricity)
    get("/energy/show", EnergyController, :show)
    get("/energy/compare", EnergyController, :compare)
    post("/energy/show", EnergyController, :show_graph)
  end

  scope "/api", HomeWeb do
    pipe_through [:api]

    get("/energy/gas_usage", ApiEnergyController, :gas_usage)
    get("/energy/hourly_gas_usage", ApiEnergyController, :hourly_gas_usage)
    get("/energy/daily_gas_usage", ApiEnergyController, :daily_gas_usage)
    get("/energy/daily_gas_and_temp", ApiEnergyController, :daily_gas_and_temp)
    get("/energy/gas_usage_per_temperature", ApiEnergyController, :gas_usage_per_temperature)
    get("/energy/gas_usage_per_temperature_per_year", ApiEnergyController, :gas_usage_per_temperature_per_year)

    get("/energy/electricity_usage", ApiEnergyController, :electricity_usage)
    get("/energy/daily_electricity_usage", ApiEnergyController, :daily_electricity_usage)
    get("/energy/hourly_electricity_usage", ApiEnergyController, :hourly_electricity_usage)
    get("/energy/current_electricity_usage", ApiEnergyController, :current_electricity_usage)
  end

  scope "/", HomeWeb do
    pipe_through [:browser]

    get("/login", LoginController, :index)
    post("/login", LoginController, :login)
  end
end
