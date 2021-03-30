defmodule HomeBot.EnergyStream.WatercookerDetector do
  use GenStage

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok)
  end

  @impl GenStage
  def init(:ok) do
    # Starts a permanent subscription to the broadcaster
    # which will automatically start requesting items.
    {:consumer, :ok, subscribe_to: [HomeBot.EnergyStream.Producer.EnergyProducer]}
  end

  @impl GenStage
  def handle_events(events, _from, state) do
    for event <- events do
      IO.inspect {self(), event}
    end
    {:noreply, [], state}
  end
end
