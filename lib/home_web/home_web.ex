defmodule HomeWeb do
  def controller do
    quote do
      use Phoenix.Controller, namespace: HomeWeb
      alias HomeWeb.Router.Helpers, as: Routes

      import Phoenix.LiveView.Controller
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/home_web/templates",
        namespace: HomeWeb

      use Phoenix.HTML
      import Phoenix.View
      import Phoenix.LiveView.Helpers
      alias HomeWeb.Router.Helpers, as: Routes
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
