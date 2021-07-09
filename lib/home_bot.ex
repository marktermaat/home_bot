defmodule HomeBot do
  use Application

  def start(_type, _args) do
    children = Application.get_env(:home_bot, :children)

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
