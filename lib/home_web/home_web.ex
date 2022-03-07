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
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import Phoenix.View
      import Phoenix.LiveView.Helpers
      alias HomeWeb.Router.Helpers, as: Routes
    end
  end

  def feature_view do
    quote do
      use Phoenix.View,
        root: "lib/home_web",
        namespace: HomeWeb

      use Phoenix.HTML
      import Phoenix.Controller, only: [get_flash: 2, view_module: 1]
      import Phoenix.View
      import Phoenix.LiveView.Helpers
      alias HomeWeb.Router.Helpers, as: Routes
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      import Phoenix.View
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
