defmodule HomeBot.EnergyStream.Producer.EnergyProducer do
  use GenStage

  alias HomeBot.EnergyStream.Producer.ProducerState

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  ## Callbacks

  @impl GenStage
  def init(:ok) do
    schedule_processing()
    {:producer, %ProducerState{latest_measurement: Timex.now()}, dispatcher: GenStage.BroadcastDispatcher}
  end

  @impl GenStage
  def handle_call({:notify, event}, _from, state) do
    state = %{state | events: :queue.in(event, state.events)}
    dispatch_events(state, [])
  end

  @impl GenStage
  def handle_demand(incoming_demand, state) do
    dispatch_events(%{state | demand: state.demand + incoming_demand}, [])
  end

  # Dispatch events, but 0 demand, so send the events so far and store the rest
  defp dispatch_events(state = %ProducerState{demand: 0}, events) do
    {:noreply, Enum.reverse(events), state}
  end

  defp dispatch_events(state, to_dispatch) do
    case :queue.out(state.events) do
      {{:value, event}, events} ->
        dispatch_events(%{state | events: events, demand: state.demand - 1}, [event | to_dispatch])

      {:empty, events} ->
        {:noreply, Enum.reverse(to_dispatch), %{state | events: events}}
    end
  end

  ## Scheduling

  defp schedule_processing(timeout \\ 10_000) do
    Process.send_after(self(), :read_data, timeout)
  end

  @impl GenStage
  def handle_info(:read_data, state) do
    {data, latest_measurement} = HomeBot.EnergyStream.Producer.EnergyData.get_new_data(state.latest_measurement)
    events = Enum.reduce(data, state.events, fn element, queue ->
      :queue.in(element, queue)
    end)

    schedule_processing()
    dispatch_events(%{state | latest_measurement: latest_measurement, events: events}, [])
  end
end
