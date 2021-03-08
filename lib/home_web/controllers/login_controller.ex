defmodule HomeWeb.LoginController do
  use HomeWeb, :controller

  def index(conn, _params) do
    conn
    |> put_layout({HomeWeb.LayoutView, "login.html"})
    |> render(:index)
  end

  def login(conn, %{"login" => %{"password" => password}}) do
    case is_valid(password) do
      true ->
        conn
        |> put_session(:logged_in, true)
        |> redirect(to: Routes.home_path(conn, :index))

      false ->
        conn
        |> put_flash(:error, "Invalid password")
        |> put_layout({HomeWeb.LayoutView, "login.html"})
        |> render(:index)
    end
  end

  defp is_valid(password) do
    stored_hash = Application.fetch_env!(:home_bot, :hashed_password)
    Bcrypt.verify_pass(password, stored_hash)
  end
end
