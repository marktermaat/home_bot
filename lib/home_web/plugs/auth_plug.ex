defmodule HomeWeb.Plugs.AuthPlug do
  import Plug.Conn
  import Phoenix.Controller

  alias HomeWeb.Router.Helpers

  def init(_params) do
  end

  def call(conn, _params) do
    logged_in = Plug.Conn.get_session(conn, :logged_in)
    if logged_in do
      conn
    else
      conn
      |> put_flash(:error, "Not logged in")
      |> redirect(to: Helpers.login_path(conn, :index))
      |> halt()
    end
  end
end
