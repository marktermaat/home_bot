defmodule HomeWeb.ErrorView do
  use HomeWeb, :view

  def render("403.html", _assigns) do
    "Unauthorized"
  end

  def render("404.html", assigns) do
    assigns.reason.message
  end

  def render("500.html", _assigns) do
    "Server-side error"
  end

  def render("500.json", _assigns) do
    "{\"error\": true}"
  end
end
