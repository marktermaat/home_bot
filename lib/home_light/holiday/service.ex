defmodule HomeLight.Holiday.Service do
  use GenServer

  alias HomeLight.Holiday.Store
  alias HomeLight.Holiday.Scheduler
  alias HomeLight.SmartLightController

  # Client

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @spec start_holiday() :: :ok
  def start_holiday() do
    GenServer.cast(__MODULE__, :start_holiday)
  end

  @spec end_holiday() :: :ok
  def end_holiday() do
    GenServer.cast(__MODULE__, :end_holiday)
  end

  @spec get_state() :: {boolean(), Time.t(), Time.t()}
  def get_state() do
    GenServer.call(__MODULE__, :get_state)
  end

  # Server

  @impl true
  def init(_) do
    state = Store.get_state()

    {:ok, state}
  end

  @impl true
  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast(:start_holiday, _old_state) do
    state = {true, Scheduler.create_schedule()}
    Store.store_state(state)
    schedule_timer()
    {:noreply, state}
  end

  @impl true
  def handle_cast(:end_holiday, _old_state) do
    state = {false, {nil, nil}}
    Store.store_state(state)
    {:noreply, state}
  end

  @impl true
  def handle_info(:check_time, {is_enabled?, schedule}) do

    case Scheduler.check_schedule(schedule) do
      :turn_on -> enable_lights()
      :turn_off -> disable_lights()
      :do_nothing -> :ok
    end

    new_schedule = Scheduler.refresh_schedule(schedule)

    if is_enabled? do
      schedule_timer()
    end

    {:noreply, {is_enabled?, new_schedule}}
  end

  defp enable_lights() do
    pid = SmartLightController.get_pid("Eettafel")
    SmartLightController.turn_on(pid)
  end

  defp disable_lights() do
    pid = SmartLightController.get_pid("Eettafel")
    SmartLightController.turn_off(pid)
  end

  defp schedule_timer() do
    Process.send_after(self(), :check_time, :timer.minutes(1))
  end
end
