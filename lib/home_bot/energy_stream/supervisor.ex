defmodule HomeBot.EnergyStream.Supervisor do
  # Automatically defines child_spec/1
  use Supervisor

  alias HomeBot.EnergyStream.Producer.EnergyProducer
  alias HomeBot.EnergyStream.Watercooker.WatercookerDetector

  def start_link(_) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    children = [
      {EnergyProducer, []},
      {WatercookerDetector, []}
    ]

    if Application.fetch_env!(:home_bot, :env) == :dev do
      Supervisor.init([], strategy: :rest_for_one)
    else
      Supervisor.init(children, strategy: :rest_for_one)
    end
  end
end